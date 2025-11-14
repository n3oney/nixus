const core = require("@actions/core");
const { spawn } = require("child_process");
const { Octokit } = require("@octokit/rest");
const github = require("@actions/github");

// Constants
const NIXOS_OWNER = "NixOS";
const NIXPKGS_REPO = "nixpkgs";
const NIXOS_UNSTABLE_BRANCH = "nixos-unstable";
const NIXPKGS_NOTIFY_PATTERN = "nixpkgs-notify #([0-9]+)";

/**
 * Validates and retrieves inputs for the action
 * @returns {Object} Inputs object with token and branch
 */
function validateInputs() {
  const token = core.getInput("github-token", { required: false });
  const branch = core.getInput("branch-to-check") || NIXOS_UNSTABLE_BRANCH;

  return { token, branch };
}

/**
 * Executes ripgrep command and returns stdout
 * @param {string} pattern - Regex pattern to search for
 * @returns {Promise<string>} Ripgrep output
 */
function executeRipgrep(pattern) {
  return new Promise((resolve, reject) => {
    const rg = spawn(
      "rg",
      [
        "--line-number",
        "--no-heading",
        "--no-column",
        "--only-matching",
        "--regexp",
        pattern,
        ".",
      ],
      {
        cwd: process.cwd(),
        stdio: ["pipe", "pipe", "pipe"],
      },
    );

    let stdout = "";
    let stderr = "";

    rg.stdout.on("data", (data) => {
      stdout += data.toString();
    });

    rg.stderr.on("data", (data) => {
      stderr += data.toString();
    });

    rg.on("close", (code) => {
      if (code !== 0 && code !== 1) {
        // rg returns 1 when no matches found
        core.error(`ripgrep error: ${stderr}`);
        reject(new Error(`ripgrep failed with code ${code}`));
        return;
      }
      resolve(stdout);
    });

    rg.on("error", reject);
  });
}

/**
 * Parses ripgrep output into structured results
 * @param {string} output - Raw ripgrep output
 * @returns {Array<{filename: string, lineNumber: number, issueNumber: number}>}
 */
function parseRipgrepOutput(output) {
  if (!output.trim()) {
    return [];
  }

  const lines = output.trim().split("\n");
  const results = [];

  for (const line of lines) {
    // Parse ripgrep output format: filename:lineNumber:match
    const match = line.match(/^([^:]+):(\d+):nixpkgs-notify #(\d+)$/);
    if (match) {
      const [, filename, lineNumber, issueNumber] = match;
      results.push({
        filename,
        lineNumber: parseInt(lineNumber, 10),
        issueNumber: parseInt(issueNumber, 10),
      });
    }
  }

  return results;
}

/**
 * Checks if a pull request has been merged into a specific branch.
 * @param {Octokit} octokit - GitHub API client
 * @param {number} prNumber - The pull request number
 * @param {string} branchName - The name of the branch to check against
 * @returns {Promise<boolean>} True if the PR is in the branch, otherwise false
 */
async function isPRInBranch(octokit, prNumber, branchName) {
  try {
    // Get the pull request to find its merge commit SHA
    const { data: pr } = await octokit.pulls.get({
      owner: NIXOS_OWNER,
      repo: NIXPKGS_REPO,
      pull_number: prNumber,
    });

    const mergeCommitSha = pr.merge_commit_sha;

    if (!mergeCommitSha) {
      core.info(`PR #${prNumber} has not been merged yet.`);
      return false;
    }

    // Compare the branch's head with the merge commit
    const { data: comparison } = await octokit.repos.compareCommits({
      owner: NIXOS_OWNER,
      repo: NIXPKGS_REPO,
      base: mergeCommitSha,
      head: branchName,
    });

    // `status` can be 'diverged', 'ahead', 'behind', or 'identical'.
    // If the branch is 'ahead' or 'identical', the merge commit is an ancestor.
    // 'behind' means the merge commit is not in the branch's history.
    return comparison.status === "ahead" || comparison.status === "identical";
  } catch (error) {
    core.error(
      `Error checking PR #${prNumber} in branch ${branchName}: ${error.message}`,
    );
    return false;
  }
}

/**
 * Gets the latest commit that modified a specific file
 * @param {Octokit} octokit - GitHub API client
 * @param {string} owner - Repository owner
 * @param {string} repo - Repository name
 * @param {string} filename - File path
 * @param {string} branch - Branch to search in
 * @returns {Promise<string|null>} Latest commit SHA or null if not found
 */
async function getLatestCommitForFile(octokit, owner, repo, filename, branch) {
  try {
    const { data: commits } = await octokit.repos.listCommits({
      owner,
      repo,
      path: filename,
      sha: branch,
      per_page: 1,
    });

    return commits.length > 0 ? commits[0].sha : null;
  } catch (error) {
    core.warning(`Failed to get latest commit for ${filename}: ${error.message}`);
    return null;
  }
}

/**
 * Checks if a comment already exists for a file/line/PR combination
 * @param {Octokit} octokit - GitHub API client
 * @param {string} owner - Repository owner
 * @param {string} repo - Repository name
 * @param {string} filename - File path
 * @param {number} lineNumber - Line number
 * @param {number} targetPrNumber - PR number we're looking for
 * @returns {Promise<boolean>} True if comment already exists
 */
async function hasExistingComment(
  octokit,
  owner,
  repo,
  filename,
  lineNumber,
  targetPrNumber,
) {
  try {
    // Get recent commits for this file and check their comments
    const { data: commits } = await octokit.repos.listCommits({
      owner,
      repo,
      path: filename,
      per_page: 10, // Check last 10 commits
    });

    // Check all commits concurrently
    const commentChecks = commits.map(async (commit) => {
      const { data: comments } = await octokit.repos.listCommentsForCommit({
        owner,
        repo,
        commit_sha: commit.sha,
      });

      return comments.some(
        (comment) =>
          comment.path === filename &&
          comment.line === lineNumber &&
          comment.body.includes(`PR #${targetPrNumber} has arrived`),
      );
    });

    const results = await Promise.all(commentChecks);
    return results.some(hasComment => hasComment);
  } catch (error) {
    core.warning(`Failed to check existing comments: ${error.message}`);
    return false;
  }
}

/**
 * Creates a commit comment on a specific line in a file
 * @param {Octokit} octokit - GitHub API client
 * @param {string} owner - Repository owner
 * @param {string} repo - Repository name
 * @param {string} commitSha - Commit SHA
 * @param {string} filename - File path
 * @param {number} lineNumber - Line number
 * @param {string} message - Comment message
 * @param {number} targetPrNumber - PR number being referenced
 */
async function createLineComment(
  octokit,
  owner,
  repo,
  commitSha,
  filename,
  lineNumber,
  message,
  targetPrNumber,
) {
  try {
    // Check if comment already exists
    const hasComment = await hasExistingComment(
      octokit,
      owner,
      repo,
      filename,
      lineNumber,
      targetPrNumber,
    );
    if (hasComment) {
      core.info(
        `Comment already exists on ${filename}:${lineNumber}, skipping`,
      );
      return;
    }

    await octokit.repos.createCommitComment({
      owner,
      repo,
      commit_sha: commitSha,
      body: message,
      path: filename,
      line: lineNumber,
    });

    core.info(`Created comment on ${filename}:${lineNumber}`);
  } catch (error) {
    core.warning(
      `Failed to create comment on ${filename}:${lineNumber}: ${error.message}`,
    );
  }
}

/**
 * Processes all results and checks PR status concurrently
 * @param {Octokit} octokit - GitHub API client
 * @param {Array} results - Parsed ripgrep results
 * @param {string} branch - Branch to check against
 * @param {Object} context - GitHub context
 * @returns {Promise<Array>} Results with PR status included
 */
async function processResults(octokit, results, branch, context) {
  if (results.length === 0) {
    core.info("No nixpkgs-notify patterns found");
    return [];
  }

  core.info(`Found ${results.length} nixpkgs-notify patterns:`);

  // Check all PRs concurrently using Promise.allSettled
  const prChecks = results.map(async (result) => {
    const isInBranch = await isPRInBranch(octokit, result.issueNumber, branch);
    return {
      ...result,
      isInBranch,
    };
  });

  const prResults = await Promise.allSettled(prChecks);

  const processedResults = [];

  for (let i = 0; i < results.length; i++) {
    const result = results[i];
    const prResult = prResults[i];

    if (prResult.status === "fulfilled") {
      const isInBranch = prResult.value.isInBranch;
      core.info(
        `${isInBranch ? "✓" : "✗"} ${result.filename}:${result.lineNumber} -> #${result.issueNumber}`,
      );

      // If PR has arrived in branch, create a commit comment on the file
      if (isInBranch) {
        const message = `Hey, PR #${result.issueNumber} has arrived in \`${branch}\`! 🎉`;
        
        // Get the latest commit that modified this file
        const commitSha = await getLatestCommitForFile(
          octokit,
          context.repo.owner,
          context.repo.repo,
          result.filename,
          'main' // Use default branch, or make this configurable
        );
        
        if (commitSha) {
          await createLineComment(
            octokit,
            context.repo.owner,
            context.repo.repo,
            commitSha,
            result.filename,
            result.lineNumber,
            message,
            result.issueNumber,
          );
        } else {
          core.warning(`Could not find commit for ${result.filename}`);
        }
      }

      processedResults.push({
        ...result,
        isInBranch,
      });
    } else {
      core.warning(
        `Failed to check PR #${result.issueNumber}: ${prResult.reason.message}`,
      );
      processedResults.push({
        ...result,
        isInBranch: false,
        error: prResult.reason.message,
      });
    }
  }

  return processedResults;
}

/**
 * Main function that orchestrates the entire process
 */
async function run() {
  try {
    // Validate inputs
    const { token, branch } = validateInputs();

    const octokit = new Octokit({ auth: token });

    if (!token) {
      core.warning("No github-token provided, may hit rate limits");
    }

    core.info("Searching for nixpkgs-notify patterns...");

    // Search for patterns using ripgrep
    const rgOutput = await executeRipgrep(NIXPKGS_NOTIFY_PATTERN);

    // Parse the output
    const results = parseRipgrepOutput(rgOutput);

    // Process results and check PR status
    const context = github.context;
    const processedResults = await processResults(
      octokit,
      results,
      branch,
      context,
    );

    // Set outputs for potential use in other steps
    core.setOutput("count", processedResults.length.toString());
    core.setOutput("results", JSON.stringify(processedResults));

    // Count merged PRs
    const mergedCount = processedResults.filter((r) => r.isInBranch).length;
    if (mergedCount > 0) {
      core.info(
        `${mergedCount} out of ${processedResults.length} PRs are merged in ${branch}`,
      );
    }
  } catch (error) {
    core.setFailed(`Action failed with error: ${error.message}`);
  }
}

// Execute the main function
if (require.main === module) {
  run();
}

module.exports = {
  run,
  validateInputs,
  executeRipgrep,
  parseRipgrepOutput,
  isPRInBranch,
  processResults,
};

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
 * Checks if a comment already exists on a specific line
 * @param {Octokit} octokit - GitHub API client
 * @param {string} owner - Repository owner
 * @param {string} repo - Repository name
 * @param {number} prNumber - Pull request number
 * @param {string} filename - File path
 * @param {number} lineNumber - Line number
 * @param {number} targetPrNumber - PR number we're looking for
 * @returns {Promise<boolean>} True if comment already exists
 */
async function hasExistingComment(
  octokit,
  owner,
  repo,
  prNumber,
  filename,
  lineNumber,
  targetPrNumber,
) {
  try {
    const { data: comments } = await octokit.pulls.listReviewComments({
      owner,
      repo,
      pull_number: prNumber,
    });

    // Check if any comment exists on this line mentioning the target PR
    return comments.some(
      (comment) =>
        comment.path === filename &&
        comment.position === lineNumber &&
        comment.body.includes(`PR #${targetPrNumber} has arrived`),
    );
  } catch (error) {
    core.warning(`Failed to check existing comments: ${error.message}`);
    return false;
  }
}

/**
 * Creates a review comment on a specific line in a pull request
 * @param {Octokit} octokit - GitHub API client
 * @param {string} owner - Repository owner
 * @param {string} repo - Repository name
 * @param {number} prNumber - Pull request number
 * @param {string} filename - File path
 * @param {number} lineNumber - Line number
 * @param {string} message - Comment message
 * @param {number} targetPrNumber - PR number being referenced
 */
async function createLineComment(
  octokit,
  owner,
  repo,
  prNumber,
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
      prNumber,
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

    // Get the PR details to get the head commit SHA
    const { data: pr } = await octokit.pulls.get({
      owner,
      repo,
      pull_number: prNumber,
    });

    await octokit.pulls.createReviewComment({
      owner,
      repo,
      pull_number: prNumber,
      commit_id: pr.head.sha,
      body: message,
      path: filename,
      position: lineNumber,
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

      // If PR has arrived in branch and we're in a PR context, create a line comment
      if (
        isInBranch &&
        context &&
        context.payload &&
        context.payload.pull_request
      ) {
        const message = `Hey, PR #${result.issueNumber} has arrived in \`${branch}\`! 🎉`;
        await createLineComment(
          octokit,
          context.repo.owner,
          context.repo.repo,
          context.payload.pull_request.number,
          result.filename,
          result.lineNumber,
          message,
          result.issueNumber,
        );
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

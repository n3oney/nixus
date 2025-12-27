{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.mcp.enable = lib.mkEnableOption "MCP";

  config.impermanence.userDirs = lib.mkIf config.services.mcp.enable [
    ".npm/_npx"
    ".local/share/memory-bank"
  ];

  config.hm = lib.mkIf config.services.mcp.enable (let
    npxDerivation = let
      nodejs = pkgs.nodejs;
    in
      pkgs.stdenv.mkDerivation {
        pname = "wrapped-npx";
        version = nodejs.version;

        nativeBuildInputs = [
          pkgs.makeWrapper
        ];

        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin

          makeWrapper ${nodejs}/bin/npx $out/bin/npx \
            --suffix PATH : "${nodejs}/bin"

          runHook postInstall
        '';

        meta = {
          description = "A wrapped npx binary that includes nodejs/bin in its PATH.";
          license = pkgs.lib.licenses.mit;
          platforms = nodejs.meta.platforms;
        };
      };
    npx = "${npxDerivation}/bin/npx";
    envFile = "/run/user/1000/agenix/mcp";

    # Helper function to wrap commands with environment variable loading
    withEnv = command: args: {
      command = "${pkgs.bash}/bin/bash";
      args = [
        "-c"
        ''
          set -a
          source ${envFile}
          set +a
          exec ${command} ${lib.concatMapStringsSep " " (arg: ''"${arg}"'') args}
        ''
      ];
    };

    servers = {
      effect = {
        command = npx;
        args = ["-y" "effect-mcp@0.1.10"];
        autoApprove = ["get_effect_doc" "effect_doc_search"];
      };

      linear = withEnv npx [
        "-y"
        "mcp-remote"
        "https://mcp.linear.app/mcp"
        "--header"
        "Authorization: $LINEAR_AUTH_TOKEN"
      ];

      github =
        (withEnv "docker" [
          "run"
          "-i"
          "--rm"
          "-e"
          "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_AUTH_TOKEN"
          "-e"
          "GITHUB_HOST"
          "ghcr.io/github/github-mcp-server"
        ])
        // {
          environment.GITHUB_HOST = "https://github.com";
        };

      nx = {
        command = npx;
        args = ["-y" "nx-mcp@latest"];
      };

      repomix = {
        command = npx;
        args = ["-y" "repomix" "--mcp"];
        autoApprove = ["grep_repomix_output" "pack_codebase"];
      };

      tavily =
        (withEnv npx [
          "-y"
          "tavily-mcp@0.2.2"
        ])
        // {
          autoApprove = ["tavily-search" "tavily-extract"];
        };

      memoryBank = {
        command = npx;
        args = ["-y" "@allpepper/memory-bank-mcp@latest"];
        environment.MEMORY_BANK_ROOT = "/home/neoney/.local/share/memory-bank";
      };

      context7 = {
        command = npx;
        args = ["-y" "@upstash/context7-mcp"];
        autoApprove = ["resolve-library-id" "get-library-docs"];
      };
    };
    instructions = ''
      You are an AI assistant helping a software engineer manage projects using a Memory Bank system. The Memory Bank is a structured documentation approach where project knowledge is stored in hierarchical files. Your memory resets between sessions, so you must rely entirely on reading all Memory Bank files before performing any work.

      ## Understanding the Memory Bank System

      The Memory Bank consists of core documentation files that capture complete project context:

      **Core Files (must exist in every project):**
      - `projectbrief.md` - Core requirements and goals
      - `productContext.md` - Problem context and solutions
      - `systemPatterns.md` - Architecture and design patterns
      - `techContext.md` - Technology stack and setup instructions
      - `activeContext.md` - Current focus and recent decisions
      - `progress.md` - Current status and roadmap

      **Custom Files (may exist depending on project):**
      - `features/*.md` - Feature specifications
      - `api/*.md` - API documentation
      - `deployment/*.md` - Deployment guides
      - Any other project-specific documentation referenced in `activeContext.md`

      ## Commands You Will Receive

      The user will issue one of these commands:

      1. **"follow your custom instructions"** or similar task requests
         - Execute the requested task
         - Requires reading all Memory Bank files first
         - Uses either Plan Mode or Act Mode

      2. **"initialize memory bank"**
         - Create new project structure
         - Establish core files
         - Perform validation checks

      3. **"update memory bank"**
         - Re-read ALL files completely from scratch
         - Update documentation based on current project state
         - Document new patterns or changes discovered

      ## Critical Requirement: Pre-Task Analysis

      Before you perform ANY task, you must complete a comprehensive pre-task analysis. This analysis must occur in your thinking process inside `<pre_task_analysis>` tags within your thinking block. It's OK for this section to be quite long - reading and analyzing 6+ core files plus custom documentation requires thoroughness.

      In your pre-task analysis, work through these steps:

      1. **Identify the trigger**: Which command or request did the user make? What exactly are they asking you to do?

      2. **List and read all required files**: Write out ALL Memory Bank files you need to read. For each file:
         - State whether you have read it or if it doesn't exist yet
         - Quote the most relevant sections from the file that apply to the current task (don't just summarize - include actual quotes to keep them top of mind)
         - Note any dependencies or relationships between files
         - Confirm which files actually exist in the project (don't reference files that don't exist)
         - If a file doesn't exist but should, make note of it

      3. **Extract applicable patterns**: From `systemPatterns.md` and other files, quote specific patterns, preferences, or constraints that apply to this specific task

      4. **Determine mode**: State whether you'll use Plan Mode or Act Mode and explain your reasoning

      5. **Identify tool needs**: List any documentation tools you'll need (context7, tavily, effect) and explain what you'll use them for

      6. **Check for violations**: Confirm you're not about to:
         - Skip reading required files
         - Hallucinate library usage instead of using documentation tools
         - Tackle unrequested tasks without permission
         - Use git commands instead of jj commands
         - Reference files that don't exist in the project

      7. **Develop execution plan**: Write a step-by-step plan for what you'll do, including:
         - Specific files or directories you'll interact with
         - Tools you'll call and in what order
         - Expected outcomes at each step

      This pre-task analysis ensures you have complete context before taking action.

      ## Your Work Process

      Follow these steps for every task:

      ### Step 1: Pre-Flight Validation

      Check the project setup:
      - Does the project directory exist?
      - Are all core files present? (`projectbrief.md`, `productContext.md`, `systemPatterns.md`, `techContext.md`, `activeContext.md`, `progress.md`)
      - If files are missing, create them before proceeding
      - Take inventory of any custom documentation files that exist

      ### Step 2: Read Memory Bank Files in Hierarchical Order

      You must read files in this specific order to build proper context:

      ```
      projectbrief.md (Core requirements and goals)
          ↓
      productContext.md (Problem context and solutions)
      systemPatterns.md (Architecture and patterns)
      techContext.md (Tech stack and setup)
          ↓
      activeContext.md (Current focus and recent decisions)
          ↓
      progress.md (Current status and roadmap)
          ↓
      Custom files (if referenced in activeContext.md)
      ```

      **CRITICAL**: You must read ALL of these files every time before performing any task. They contain the complete context you need to work effectively.

      ### Step 3: Select and Execute in Appropriate Mode

      Choose the mode based on what the task requires:

      #### Plan Mode

      Use Plan Mode when you need to:
      - Understand what projects exist
      - Select relevant context
      - Develop a strategy before taking action

      Process:
      1. Use `filesystem/list_directory` to list available projects
      2. Select the relevant context for the task
      3. Develop a strategy and document it in `activeContext.md`
      4. Validate that all file paths use forward slashes (not backslashes)

      #### Act Mode

      Use Act Mode when you're ready to execute a specific task.

      Process:
      1. Review `systemPatterns.md` to understand project-specific patterns
      2. Execute the task according to your strategy
      3. When you need library or API documentation:
         - Use `context7` for library documentation
         - Use `tavily` to search the web
         - Use the `effect` tool for Effect library documentation
         - NEVER hallucinate or guess at library usage - always verify with these tools first

      **Version Control Commands:**
      Use jj (jujutsu) commands exclusively - do NOT use git:
      - `jj pull; jj sync` - Pull latest changes
      - `jj tug; jj push` - Push changes
      - `jj commit` - Commit everything edited (no separate add step needed)

      **JSON Operations Format:**
      When performing operations that require JSON, use this exact format:
      ```json
      {
        "projectName": "project-id",
        "fileName": "progress.md",
        "content": "Content with\\nescaped newlines"
      }
      ```

      Requirements:
      - Use `\\n` for newlines (not literal newlines)
      - Use pure JSON (no XML mixing)
      - Use lowercase for booleans: `true` and `false`

      ### Step 4: Determine If Memory Bank Update Is Needed

      Update the Memory Bank when ANY of these conditions occur:
      - Changes impact ≥25% of the codebase
      - You discover a new pattern worth documenting
      - User explicitly requests "update memory bank"
      - Context becomes ambiguous or unclear
      - You notice discrepancies between documentation and actual code

      **Update Process:**

      1. **Re-read completely**: Re-read ALL Memory Bank files from scratch (start with a fresh perspective)

      2. **Update in reverse order**: Update files in reverse hierarchical order:
         - Start with `progress.md` (most specific/current)
         - Then `activeContext.md`
         - Then other files as needed

      3. **Learning Process** - Identify and document patterns:
         - Identify patterns in implementation, workflow, or decisions
         - Validate patterns with user when appropriate
         - Update `systemPatterns.md` with validated patterns
         - Apply these patterns to future work

      4. **Ensure `systemPatterns.md` captures**:
         - Critical implementation paths
         - User workflow preferences
         - Tool usage patterns
         - Project-specific architectural decisions

      ## Important Constraints

      **DO NOT:**
      - Skip reading Memory Bank files before working - this is your only source of project knowledge
      - Tackle tasks you weren't asked to do without explicit confirmation
        - Example: If implementing a feature reveals other type errors elsewhere, don't fix them unless asked
      - Hallucinate library usage or APIs
        - You have documentation tools (context7, tavily, effect) - use them
        - Using these tools is free and ensures accuracy
      - Use git commands - always use jj (jujutsu) instead
      - Reference files that don't exist in the project

      **DO:**
      - Read ALL Memory Bank files before EVERY task
      - Use documentation tools to verify library usage instead of guessing
      - Ask for confirmation before expanding task scope
      - Follow the hierarchical file reading order
      - Update `systemPatterns.md` as you learn project patterns
      - Validate that files actually exist before referencing them

      ## Memory Bank File Relationships

      Understanding how files relate helps you read them effectively:

      ```
      projectbrief.md (Foundation: What we're building and why)
          ↓
      productContext.md (Problem space: What problems we're solving)
      systemPatterns.md (Solution space: How we solve them)
      techContext.md (Implementation: Technologies we use)
          ↓
      activeContext.md (Current work: What we're focused on now)
          ↓
      progress.md (Status: Where we are in the journey)
          ↓
      Custom files (Details: Specific feature/API/deployment docs)
      ```

      ## Complete Workflow

      ```mermaid
      flowchart TD
          Start[Receive User Command] --> PreTask[Pre-Task Analysis]
          PreTask --> PreFlight[Pre-Flight Validation]

          PreFlight --> CheckProj{Project exists?}
          CheckProj -->|No| CreateProj[Create project]
          CheckProj -->|Yes| CheckFiles{Core files exist?}

          CreateProj --> CreateFiles[Create missing files]
          CheckFiles -->|No| CreateFiles
          CheckFiles -->|Yes| ReadAll[Read ALL Memory Bank Files]
          CreateFiles --> ReadAll

          ReadAll --> Mode{Which mode?}

          Mode -->|Plan| PlanMode[List projects, select context, develop strategy]
          Mode -->|Act| ActMode[Execute task, use doc tools if needed]

          PlanMode --> CheckUpdate
          ActMode --> CheckUpdate{Update needed?}

          CheckUpdate -->|Yes: ≥25% changes| UpdateMB[Re-read all files, update docs, identify patterns]
          CheckUpdate -->|Yes: New patterns| UpdateMB
          CheckUpdate -->|Yes: User request| UpdateMB
          CheckUpdate -->|Yes: Context unclear| UpdateMB
          CheckUpdate -->|No| End[Complete]

          UpdateMB --> End
      ```

      ## Final Reminder

      Your effectiveness depends entirely on reading and understanding the complete Memory Bank context before every task. Take the time to read all files thoroughly - this is your only source of project knowledge between sessions. The pre-task analysis you perform in your thinking block ensures you have complete context and follow all requirements before taking action.

      After completing your pre-task analysis in your thinking block, provide your final response. Your final output should consist only of the actions taken, results, or information requested for the task. Do not repeat or rehash the analytical work from your pre-task analysis in your final response.
    '';
  in {
    programs.opencode.settings = {
      instructions = [(pkgs.writeText "instructions.md" instructions)];
      mcp = lib.mapAttrs (name: value:
        {
          enabled = true;
          type = "local";
          command = [value.command] ++ value.args;
        }
        // lib.optionalAttrs (value ? environment) {
          inherit (value) environment;
        })
      servers;
    };
  });
}

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
      # Memory Bank via MCP

      I'm an expert engineer whose memory resets between sessions. I rely ENTIRELY on my Memory Bank, accessed via MCP tools, and MUST read ALL memory bank files before EVERY task.
      I use the Effect pattern skills when neccessary.

      ## Key Commands

      1. "follow your custom instructions"

         - Triggers Pre-Flight Validation (\*a)
         - Follows Memory Bank Access Pattern (\*f)
         - Executes appropriate Mode flow (Plan/Act)

      2. "initialize memory bank"

         - Follows Pre-Flight Validation (\*a)
         - Creates new project if needed
         - Establishes core files structure (\*f)

      3. "update memory bank"
         - Triggers Documentation Updates (\*d)
         - Performs full file re-read
         - Updates based on current state

      ## Memory Bank lyfe cycle:

      ```mermaid
      flowchart TD
          A[Start] --> B["Pre-Flight Validation (*a)"]
          B --> C{Project Exists?}
          C -->|Yes| D[Check Core Files]
          C -->|No| E[Create Project] --> H[Create Missing Files]

          D --> F{All Files Present?}
          F -->|Yes| G["Access Memory Bank (*f)"]
          F -->|No| H[Create Missing Files]

          H --> G
          G --> I["Plan Mode (*b)"]
          G --> J["Act Mode (*c)"]

          I --> K[List Projects]
          K --> L[Select Context]
          L --> M[Develop Strategy]

          J --> N[Read .clinerules]
          N --> O[Execute Task]
          O --> P["Update Documentation (*d)"]

          P --> Q{Update Needed?}
          Q -->|Patterns/Changes| R[Read All Files]
          Q -->|User Request| R
          R --> S[Update Memory Bank]

          S --> T["Learning Process (*e)"]
          T --> U[Identify Patterns]
          U --> V[Validate with User]
          V --> W[Update .clinerules]
          W --> X[Apply Patterns]
          X --> O

          %% Intelligence Connections
          W -.->|Continuous Learning| N
          X -.->|Informed Execution| O
      ```

      ## Phase Index & Requirements

      a) **Pre-Flight Validation**

      - **Triggers:** Automatic before any operation
      - **Checks:**
        - Project directory existence
        - Core files presence (projectbrief.md, productContext.md, etc.)
        - Custom documentation inventory

      b) **Plan Mode**

      - **Inputs:** Filesystem/list_directory results
      - **Outputs:** Strategy documented in activeContext.md
      - **Format Rules:** Validate paths with forward slashes

      c) **Act Mode**

      - **JSON Operations:**
        ```json
        {
          "projectName": "project-id",
          "fileName": "progress.md",
          "content": "Escaped\\ncontent"
        }
        ```
      - **Requirements:**
        - Use \\n for newlines
        - Pure JSON (no XML)
        - Boolean values lowercase (true/false)

      d) **Documentation Updates**

      - **Triggers:**
        - ≥25% code impact changes
        - New pattern discovery
        - User request "update memory bank"
        - Context ambiguity detected
      - **Process:** Full file re-read before update

      e) **Project Intelligence**

      - **.clinerules Requirements:**
        - Capture critical implementation paths
        - Document user workflow preferences
        - Track tool usage patterns
        - Record project-specific decisions
      - **Cycle:** Continuous validate → update → apply

      f) **Memory Bank Structure**

      ```mermaid
      flowchart TD
          PB[projectbrief.md\nCore requirements/goals] --> PC[productContext.md\nProblem context/solutions]
          PB --> SP[systemPatterns.md\nArchitecture/patterns]
          PB --> TC[techContext.md\nTech stack/setup]

          PC --> AC[activeContext.md\nCurrent focus/decisions]
          SP --> AC
          TC --> AC

          AC --> P[progress.md\nStatus/roadmap]

          %% Custom files section
          subgraph CF[Custom Files]
              CF1[features/*.md\nFeature specs]
              CF2[api/*.md\nAPI documentation]
              CF3[deployment/*.md\nDeployment guides]
          end

          %% Connect custom files to main structure
          AC -.-> CF
          CF -.-> P

          style PB fill:#e066ff,stroke:#333,stroke-width:2px
          style AC fill:#4d94ff,stroke:#333,stroke-width:2px
          style P fill:#2eb82e,stroke:#333,stroke-width:2px
          style CF fill:#fff,stroke:#333,stroke-width:1px,stroke-dasharray: 5 5
          style CF1 fill:#fff,stroke:#333
          style CF2 fill:#fff,stroke:#333
          style CF3 fill:#fff,stroke:#333
      ```

      - **File Relationships:**
        - projectbrief.md feeds into all context files
        - All context files inform activeContext.md
        - progress.md tracks implementation based on active context
      - **Color Coding:**
        - Purple: Foundation documents
        - Blue: Active work documents
        - Green: Status tracking
        - Dashed: Custom documentation (flexible/optional)
      - **Access Pattern:**

        - Always read in hierarchical order
        - Update in reverse order (progress → active → others)
        - .clinerules accessed throughout process
        - Custom files integrated based on project needs

      - **Custom Files:**
        - Can be added when specific documentation needs arise
        - Common examples:
          - Feature specifications
          - API documentation
          - Integration guides
          - Testing strategies
          - Deployment procedures
        - Should follow main structure's naming patterns
        - Must be referenced in activeContext.md when added

      Use context7 for library documentation.
      Use tavily to search the web for information. If working with effect, use the effect tool to get proper documentation.

      Do not tackle tasks you were not asked to do without asking for confirmation. For example, if you implement a new feature, and then run typechecks to test if it's correct, do not go out of your way to fix other type errors.
      Do not hallucinate library usages. You have the tools for documentation for a reason. Use the tools, it doesn't cost you anything, and you won't look like a fool on drugs hallucinating libraries.
      Do not use git. Use jj (jujutsu) instead. `jj pull; jj sync` will pull the latest changes, `jj tug; jj push` will push the changes. Remember that running `jj commit` will commit everything that was edited - there is no `git add`.
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

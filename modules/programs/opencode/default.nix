{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  geminiAuthPlugin = import ./gemini-auth.nix {inherit pkgs;};
  # anthropicAuthPlugin = import ./anthropic-auth.nix {inherit pkgs;};

  opencode = inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
  # effect-patterns repo seems to be in a weird state
  /*
  effectPatternsPath = "${inputs.EffectPatterns}/content/published/patterns";
  # Get all pattern directories
  patternDirs = builtins.attrNames (
    lib.filterAttrs (_: v: v == "directory") (builtins.readDir effectPatternsPath)
  );

  # For each pattern directory, get all .mdx files and create skill entries
  getPatternFiles = patternName: let
    patternPath = "${effectPatternsPath}/${patternName}";
    files = builtins.attrNames (builtins.readDir patternPath);
    mdxFiles = builtins.filter (f: lib.hasSuffix ".mdx" f) files;
  in
    builtins.map (fileName: {
      inherit patternName fileName;
      skillName = lib.removeSuffix ".mdx" fileName;
      content = builtins.readFile "${patternPath}/${fileName}";
    })
    mdxFiles;


  # Flatten all pattern files
  allPatternFiles = builtins.concatMap getPatternFiles patternDirs;

  # Create xdg.configFile entries for each skill
  # Structure: effect-patterns/<skill-name>/SKILL.md
  skillConfigFiles = builtins.listToAttrs (
    builtins.map (file: let
      # Flatten "rule:\n  " to bring description to top level
      content = builtins.replaceStrings ["rule:\n  "] [""] file.content;
      lines = lib.splitString "\n" content;
      # Insert `name:` after the first line (the opening ---)
      skillContent = builtins.concatStringsSep "\n" (
        [(builtins.head lines) "name: ${file.skillName}"] ++ (builtins.tail lines)
      );
    in {
      name = "opencode/skill/effect-patterns-${file.skillName}/SKILL.md";
      value.text = skillContent;
    })
    allPatternFiles
  );
  */
in {
  options.programs.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf config.programs.opencode.enable {
    impermanence.userDirs = [
      ".local/share/opencode"
      ".cache/opencode"
      ".local/state/opencode"
    ];

    hm = {
      home.file.".local/state/opencode/model.json".text = builtins.toJSON {
        recent = [];
        variant = {};
        favorite = [
          {
            providerID = "google";
            modelID = "gemini-3-pro-preview";
          }
          {
            providerID = "anthropic";
            modelID = "claude-opus-4-5";
          }
          {
            providerID = "anthropic";
            modelID = "claude-sonnet-4-5";
          }
          {
            providerID = "anthropic";
            modelID = "claude-haiku-4-5";
          }
        ];
      };

      xdg.configFile =
        /*
          skillConfigFiles
        //
        */
        {
          "opencode/dcp.jsonc".text = builtins.toJSON {
            enabled = false; # disabled for now - breaks caching on anthropic
            debug = false;
            pruneNotification = "minimal";
            turnProtection = {
              enabled = true;
              turns = 5;
            };

            tools = {
              settings = {
                nudgeEnabled = true;
                nudgeFrequency = 10;
                protectedTools = [];
              };
              discard = {
                enabled = true;
              };
              extract = {
                enabled = true;
                showDistillation = true;
              };
            };
            strategies = {
              deduplication = {
                enabled = true;
                protectedTools = [];
              };
              supersedeWrites = {
                enabled = true;
              };
              purgeErrors = {
                enabled = true;
                turns = 4;
                protectedTools = [];
              };
            };
          };
        };

      programs.opencode = {
        package = opencode;
        enable = true;
        settings = {
          agent = {
            plan.model = "anthropic/claude-opus-4-5";
            build.model = "anthropic/claude-sonnet-4-5";
            explore.model = "anthropic/claude-haiku-4-5";
            general.model = "anthropic/claude-sonnet-4-5";
            compaction.model = "anthropic/claude-haiku-4-5";
          };
          permission.lsp = "allow";
          provider.google.options.projectId = "gen-lang-client-0105823012";
          plugin = [
            "@mohak34/opencode-notifier@latest"

            #"@nick-vi/opencode-type-inject"

            "file://${geminiAuthPlugin}"
            # "file://${anthropicAuthPlugin}"
            "@franlol/opencode-md-table-formatter@0.0.3"
            "@tarquinen/opencode-dcp@latest"
          ];
          theme = "system";
          instructions = [".github/copilot-instructions.md"];
          model = "google/gemini-3-pro-preview";
          small_model = "zai-coding-plan/glm-4.5-air";
        };
      };
    };
  };
}

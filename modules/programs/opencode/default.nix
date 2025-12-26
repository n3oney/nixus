{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
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
in {
  options.programs.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf config.programs.opencode.enable {
    impermanence.userDirs = [
      ".local/share/opencode"
      ".cache/opencode"
    ];

    hm = {
      programs.opencode = {
        package = inputs.nix-ai-tools.packages.${pkgs.system}.opencode.overrideAttrs (old: {
          # patches = (old.patches or []) ++ [./0000-opencode.patch];
        });
        enable = true;
        settings = {
          plugin = ["@franlol/opencode-md-table-formatter@0.0.3"];
          theme = "system";
          instructions = [".github/copilot-instructions.md"];
          model = "zai-coding-plan/glm-4.6";
          small_model = "zai-coding-plan/glm-4.5-air";
        };
      };

      # Create skill directories in ~/.config/opencode/skills/
      xdg.configFile = skillConfigFiles;
    };
  };
}

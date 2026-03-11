{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  opencodeNotifierPlugin = import ./opencode-notifier.nix {
    inherit pkgs;
    src = inputs.opencode-notifier;
  };

  opencode = inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  # Build a derivation that generates SKILL.md files from all EffectPatterns MDX files.
  # Uses a bash script to handle arbitrary nesting depth (schema/ has subdirs).
  effectPatternsSkills = pkgs.runCommand "effect-patterns-skills" {} ''
        mkdir -p $out

        find ${inputs.EffectPatterns}/content/published/patterns -name '*.mdx' | while read -r mdx; do
          # Extract id and summary from YAML frontmatter
          id=$(${pkgs.gawk}/bin/awk '/^---$/ { count++; next } count == 1 && /^id:/ { sub(/^id: */, ""); print; exit }' "$mdx")
          # Handle both single-line and multi-line (>-) summary values
          summary=$(${pkgs.gawk}/bin/awk '
            /^---$/ { count++; next }
            count >= 2 { exit }
            count == 1 && /^summary:/ {
              sub(/^summary: */, "")
              # Check for >- or > (folded block scalar)
              if ($0 == ">-" || $0 == ">") {
                summary = ""
                while (getline > 0) {
                  if (/^[^ ]/ && !/^  /) break
                  sub(/^  /, "")
                  if (summary != "") summary = summary " "
                  summary = summary $0
                }
                print summary
              } else {
                # Remove surrounding quotes if present
                gsub(/^\x27/, ""); gsub(/\x27$/, "")
                gsub(/^"/, ""); gsub(/"$/, "")
                print
              }
              exit
            }
          ' "$mdx")

          if [ -z "$id" ]; then
            echo "WARNING: No id found in $mdx, skipping"
            continue
          fi

          if [ -z "$summary" ]; then
            summary="Effect pattern: $id"
          fi

          # Truncate description to 1024 chars (OpenCode limit)
          summary="''${summary:0:1024}"

          # Extract body (everything after the closing --- of frontmatter)
          body=$(${pkgs.gawk}/bin/awk '
            /^---$/ { count++; if (count == 2) { found=1; next } next }
            found { print }
          ' "$mdx")

          # Create skill directory and SKILL.md
          skillDir="$out/$id"
          mkdir -p "$skillDir"
          cat > "$skillDir/SKILL.md" << SKILL_EOF
    ---
    name: $id
    description: $summary
    ---
    $body
    SKILL_EOF
        done
  '';

  # Generate xdg.configFile entries from the built skill derivation
  skillDirs = builtins.attrNames (
    lib.filterAttrs (_: v: v == "directory") (builtins.readDir effectPatternsSkills)
  );
  skillConfigFiles = builtins.listToAttrs (
    builtins.map (skillName: {
      name = "opencode/skills/${skillName}/SKILL.md";
      value.source = "${effectPatternsSkills}/${skillName}/SKILL.md";
    })
    skillDirs
  );
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
            providerID = "anthropic";
            modelID = "claude-opus-4-6";
          }
          {
            providerID = "anthropic";
            modelID = "claude-sonnet-4-6";
          }
          {
            providerID = "anthropic";
            modelID = "claude-haiku-4-5";
          }
        ];
      };

      xdg.configFile = skillConfigFiles;
      programs.opencode = {
        package = opencode;
        enable = true;
        settings = {
          agent = {
            plan.model = "anthropic/claude-opus-4-6";
            build.model = "anthropic/claude-sonnet-4-6";
            explore.model = "anthropic/claude-haiku-4-5";
            general.model = "anthropic/claude-sonnet-4-6";
            compaction.model = "anthropic/claude-haiku-4-5";
          };
          permission.lsp = "allow";
          plugin = [
            "file://${opencodeNotifierPlugin}"

            #"@nick-vi/opencode-type-inject"
          ];
          theme = "system";
          instructions = [".github/copilot-instructions.md"];
        };
      };
    };
  };
}

{
  pkgs,
  config,
  lib,
  inputs,
  hmConfig,
  ...
}: let
  # Build a derivation that generates SKILL.md files from all EffectPatterns MDX files.
  # Same logic as the opencode module — Claude Code's skills format is identical
  # (a directory per skill containing SKILL.md with YAML frontmatter).
  effectPatternsSkills = pkgs.runCommand "effect-patterns-skills" {} ''
        mkdir -p $out

        find ${inputs.EffectPatterns}/content/published/patterns -name '*.mdx' | while read -r mdx; do
          id=$(${pkgs.gawk}/bin/awk '/^---$/ { count++; next } count == 1 && /^id:/ { sub(/^id: */, ""); print; exit }' "$mdx")
          summary=$(${pkgs.gawk}/bin/awk '
            /^---$/ { count++; next }
            count >= 2 { exit }
            count == 1 && /^summary:/ {
              sub(/^summary: */, "")
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

          summary="''${summary:0:1024}"

          body=$(${pkgs.gawk}/bin/awk '
            /^---$/ { count++; if (count == 2) { found=1; next } next }
            found { print }
          ' "$mdx")

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

  # Map each generated skill directory into the `skills` attrset expected
  # by home-manager's programs.claude-code module.
  skillDirs = builtins.attrNames (
    lib.filterAttrs (_: v: v == "directory") (builtins.readDir effectPatternsSkills)
  );
  skills = builtins.listToAttrs (
    builtins.map (skillName: {
      name = skillName;
      value = "${effectPatternsSkills}/${skillName}";
    })
    skillDirs
  );
in {
  options.programs.claude-code.enable = lib.mkEnableOption "claude-code";

  config = lib.mkIf config.programs.claude-code.enable {
    impermanence.userDirs = [
      ".claude"
      ".config/claude"
      ".cache/claude"
    ];

    impermanence.userFiles = [".claude.json"];

    hm = {
      home.packages = [pkgs.sox];
      programs.claude-code = {
        enable = true;
        # Patch the /buddy salt so the companion rolls as a legendary cat.
        # See https://gist.github.com/rinnathecat/0c554c10193b3b8dfac0be338c3d51ee
        package = (inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.claude-code).overrideAttrs (old: {
          postFixup =
            (old.postFixup or "")
            + ''
              for f in $(grep -rlF 'friend-2026-401' $out 2>/dev/null); do
                chmod +w "$f"
                ${pkgs.perl}/bin/perl -i -pe 'BEGIN{undef $/} s/friend-2026-401/stm4u4c_fmh77_t/g' "$f"
              done
            '';
        });

        inherit skills;

        settings = {
          voiceEnabled = true;
          theme = "dark";
          permissions = {
            allow = ["mcp__lsp"];
            ask = ["mcp__postgresMutable"];
          };
        };
      };
    };
  };
}

{
  pkgs,
  lib,
  inputs,
}: let
  drv = pkgs.runCommand "effect-patterns-skills" {} ''
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

  skillDirs = builtins.attrNames (
    lib.filterAttrs (_: v: v == "directory") (builtins.readDir drv)
  );
in {
  inherit drv skillDirs;
}

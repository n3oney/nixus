{
  pkgs,
  config,
  lib,
  inputs,
  hmConfig,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
  effectPatterns = import ../effect-patterns-skills.nix {inherit pkgs lib inputs;};
  skills = lib.genAttrs effectPatterns.skillDirs (name: "${effectPatterns.drv}/${name}");
in {
  options.programs.claude-code = {
    enable = lib.mkEnableOption "claude-code";

    mcpServers = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
      default = {};
      description = "MCP servers to merge into ~/.claude.json via activation script";
    };
  };

  config = lib.mkIf config.programs.claude-code.enable {
    impermanence.userDirs = [
      ".claude"
      ".config/claude"
      ".cache/claude"
    ];

    impermanence.userFiles = [".claude.json"];

    hm = {
      home.packages = [pkgs.sox];

      home.activation.claudeMcpServers = let
        mcpConfigFile = jsonFormat.generate "claude-mcp-servers.json" {
          mcpServers = config.programs.claude-code.mcpServers;
        };
        jq = lib.getExe pkgs.jq;
      in
        lib.mkIf (config.programs.claude-code.mcpServers != {}) (
          hmConfig.lib.dag.entryAfter ["writeBoundary"] ''
            claude_json="$HOME/.claude.json"
            if [ -f "$claude_json" ]; then
              merged=$(${jq} -s '.[0] * .[1]' "$claude_json" ${mcpConfigFile})
              printf '%s\n' "$merged" > "$claude_json"
            else
              cp ${mcpConfigFile} "$claude_json"
            fi
          ''
        );

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

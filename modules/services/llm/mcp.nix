{
  config,
  lib,
  pkgs,
  ...
}: let
  npx = "${pkgs.writeShellScriptBin "npx" ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    exec ${pkgs.nodejs}/bin/npx "$@"
  ''}/bin/npx";

  envFile = "/run/user/1000/agenix/mcp";

  # Quote args for bash double-quoted context so $VAR expansion still works.
  # lib.escapeShellArgs single-quotes, which would pass `$LINEAR_AUTH_TOKEN` through literally.
  escapeDQ = builtins.replaceStrings ["\\" "\"" "`"] ["\\\\" "\\\"" "\\`"];
  quoteArgs = args: lib.concatMapStringsSep " " (a: ''"${escapeDQ a}"'') args;

  withEnv = command: args: {
    command = "${pkgs.bash}/bin/bash";
    args = [
      "-c"
      ''
        set -a
        source ${envFile}
        set +a
        exec ${command} ${quoteArgs args}
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

    postgresReadOnly = {
      command = "${pkgs.podman}/bin/podman";
      args = [
        "run"
        "-i"
        "--rm"
        "-e"
        "DATABASE_URI"
        "docker.io/crystaldba/postgres-mcp"
        "--access-mode=restricted"
      ];

      environment.DATABASE_URI = "{env:DATABASE_URI}";
    };

    postgresMutable = {
      command = "${pkgs.podman}/bin/podman";
      args = [
        "run"
        "-i"
        "--rm"
        "-e"
        "DATABASE_URI"
        "docker.io/crystaldba/postgres-mcp"
        "--access-mode=unrestricted"
      ];

      environment.DATABASE_URI = "{env:DATABASE_URI}";
    };

    tavily =
      (withEnv npx [
        "-y"
        "tavily-mcp@0.2.2"
      ])
      // {
        autoApprove = ["tavily-search" "tavily-extract"];
      };

    context7 = {
      command = npx;
      args = ["-y" "@upstash/context7-mcp"];
      autoApprove = ["resolve-library-id" "get-library-docs"];
    };
  };

  toClaudeServer = _: value: let
    literalEnv =
      lib.filterAttrs (_: v: !(lib.isString v && lib.hasInfix "{env:" v))
      (value.environment or {});
  in
    {
      inherit (value) command args;
    }
    // lib.optionalAttrs (literalEnv != {}) {env = literalEnv;}
    // lib.optionalAttrs (value ? autoApprove) {
      inherit (value) autoApprove;
    };
in {
  options.services.mcp.enable = lib.mkEnableOption "MCP";

  config.impermanence.userDirs = lib.mkIf config.services.mcp.enable [
    ".npm/_npx"
  ];

  config.programs.claude-code.mcpServers = lib.mkIf config.services.mcp.enable (
    lib.mapAttrs toClaudeServer servers
  );
}

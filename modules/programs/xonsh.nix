{
  pkgs,
  lib,
  config,
  osConfig,
  hmConfig,
  inputs,
  ...
}: let
  bg = config.colors.colorScheme.palette.base00;
  rgb =
    lib.concatStringsSep "/"
    (builtins.match "([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})" bg);
  alpha = lib.toHexString (builtins.floor (config.colors.backgroundAlpha * 255));

  lsColorsFile = pkgs.runCommand "ls-colors" {} ''
    env COLORTERM=truecolor ${lib.getExe pkgs.vivid} generate catppuccin-macchiato | tr -d '\n' > $out
  '';
in {
  config = {
    impermanence.userDirs = [".local/share/xonsh"];

    os.users.defaultUserShell = osConfig.programs.xonsh.package;

    os.programs.xonsh = {
      enable = true;
      package = inputs.xonsh.packages.${pkgs.stdenv.hostPlatform.system}.xonsh;
      config = ''
        import os, sys, subprocess

        aliases['cat'] = '${lib.getExe pkgs.bat}'

        _eza = '${lib.getExe pkgs.eza} --icons=auto --git'
        aliases.update({
            'ls':  _eza,
            'll':  _eza + ' -l',
            'la':  _eza + ' -a',
            'lla': _eza + ' -la',
            'lt':  _eza + ' --tree',
        })


        execx($(${lib.getExe hmConfig.programs.zoxide.package} init xonsh))
        aliases['cd'] = 'z'

        ${lib.optionalString config.programs.atuin.enable ''
          execx($(${lib.getExe hmConfig.programs.atuin.package} init xonsh))
        ''}

        def _hd(args):
            if '--' in args:
                idx = args.index('--')
                before, after = args[:idx], args[idx+1:]
            else:
                before, after = args, []
            with ''${...}.swap(NIX_SSHOPTS='-o Compression=no'):
                return subprocess.run(
                    ['nh', 'os', 'switch', '--use-substitutes', *before, '--', '--impure', *after]
                ).returncode
        aliases['hd'] = _hd

        def _opaquewrap(binary):
            def _run(args):
                sys.stdout.write('\033]11;rgba:${rgb}/ff\007'); sys.stdout.flush()
                try:
                    return subprocess.run([binary, *args]).returncode
                finally:
                    sys.stdout.write('\033]11;rgba:${rgb}/${alpha}\007'); sys.stdout.flush()
            return _run
        for _bin in ('nvim', 'vim', 'vi', 'hx', 'btop'):
            aliases[_bin] = _opaquewrap(_bin)

        $ENABLE_ASYNC_PROMPT = True
        $XONSH_AUTOPAIR = True
        $XONSH_HISTORY_BACKEND = 'sqlite'
        $XONSH_HISTORY_SIZE = (1000000, 'commands')
        # direnv replaces PATH with a nix-shell minimal bash that lacks
        # programmable completion (no `complete` builtin), breaking the
        # bash completion bridge inside direnv shells. Pin to the full
        # interactive bash so completion works everywhere.
        $XONSH_BASH_PATH_OVERRIDE = '${pkgs.bashInteractive}/bin/bash'

        @events.on_command_not_found
        def _cnf(cmd, **kw):
            print(f'Command {cmd[0]} not found. Prefix it with a , to fetch from nixpkgs.')

        from xonsh.pyghooks import register_custom_pygments_style
        from pygments.token import Token

        _palette = {
            'BLACK':  '#${config.colors.colorScheme.palette.base02}',
            'RED':    '#${config.colors.colorScheme.palette.base08}',
            'GREEN':  '#${config.colors.colorScheme.palette.base0B}',
            'YELLOW': '#${config.colors.colorScheme.palette.base0A}',
            'BLUE':   '#${config.colors.colorScheme.palette.base0D}',
            'PURPLE': '#${config.colors.colorScheme.palette.base0E}',
            'CYAN':   '#${config.colors.colorScheme.palette.base0C}',
            'WHITE':  '#${config.colors.colorScheme.palette.base05}',
        }
        _color_map = {}
        for _name, _hex in _palette.items():
            _color_map[getattr(Token.Color, _name)] = _hex
            _color_map[getattr(Token.Color, f'INTENSE_{_name}')] = _hex
        # base16 splits the BLACK/WHITE intensities across additional slots
        _color_map[Token.Color.INTENSE_BLACK] = '#${config.colors.colorScheme.palette.base03}'
        _color_map[Token.Color.INTENSE_WHITE] = '#${config.colors.colorScheme.palette.base06}'
        register_custom_pygments_style('nixus-base16', _color_map)
        $XONSH_COLOR_STYLE = 'nixus-base16'

        # Subprocess LS_COLORS via vivid (truecolor) — bypasses xonsh's
        # detype roundtrip which downgrades RGB. Independent of the
        # custom pygments style above (which handles xonsh's own prompt
        # and menu rendering).
        from xonsh.environ import LsColors
        with open('${lsColorsFile}') as _f:
            _ls_colors = _f.read()
        class _RawLsColors(LsColors):
            def detype(self):
                return self._raw
        _ls_obj = _RawLsColors.fromstring(_ls_colors)
        _ls_obj._raw = _ls_colors
        __xonsh__.env._d['LS_COLORS'] = _ls_obj

        execx($(${lib.getExe pkgs.starship} init xonsh))

        _starship_left = $PROMPT
        $PROMPT = lambda: _starship_left().rstrip('\n')
        del $RIGHT_PROMPT
      '';
    };
  };
}

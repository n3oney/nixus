{
  impurity,
  config,
  pkgs,
  lib,
  hmConfig,
  ...
}: let
  # emacsPkgs = inputs.emacs-overlay.packages.${pkgs.system};
  ts-parsers = grammars:
    builtins.attrValues {
      inherit
        (grammars)
        tree-sitter-bash
        tree-sitter-css
        tree-sitter-elisp
        tree-sitter-javascript
        tree-sitter-json
        tree-sitter-json5
        tree-sitter-markdown
        tree-sitter-markdown-inline
        tree-sitter-nix
        tree-sitter-prisma
        tree-sitter-regex
        tree-sitter-rust
        tree-sitter-scss
        tree-sitter-sql
        tree-sitter-toml
        tree-sitter-tsx
        tree-sitter-typescript
        tree-sitter-yaml
        ;
    };

  emacsWithoutPath =
    (pkgs.emacsPackagesFor
      (pkgs.emacs29-pgtk.override {
        withNativeCompilation = true;
      }))
    .emacsWithPackages
    (
      epkgs:
        builtins.attrValues {
          inherit
            (epkgs)
            avy
            better-jumper
            company
            crux
            catppuccin-theme
            cmake-font-lock
            direnv
            editorconfig
            evil
            evil-collection
            evil-goggles
            face-explorer
            format-all
            flycheck
            frames-only-mode
            fussy
            just-mode
            lsp-mode
            lsp-treemacs
            lsp-ui
            magit
            markdown-mode
            nix-mode
            reformatter
            rust-mode
            projectile
            rainbow-mode
            string-inflection
            treemacs
            treemacs-evil
            treemacs-projectile
            treemacs-magit
            undo-tree
            use-package
            vertico
            which-key
            ws-butler
            ;
          ts-grammars =
            epkgs.treesit-grammars.with-grammars ts-parsers;
        }
    );

  emacs = let
    packages = builtins.attrValues {
      inherit (pkgs) nil alejandra rust-analyzer rustfmt;
    };
  in
    pkgs.stdenv.mkDerivation {
      name = emacsWithoutPath.name;
      src = emacsWithoutPath;

      buildInputs = [pkgs.makeWrapper];

      installPhase = ''
        mkdir $out
        cp -R $src/* $out

        chmod -R 777 $out/bin

        for program in $out/bin/*; do
          wrapProgram $program \
            --prefix PATH : "${lib.makeBinPath packages}"
         done

        chmod -R 555 $out/bin
      '';
    };
in {
  options.programs.emacs.enable = lib.mkEnableOption "emacs";

  config.hm = lib.mkIf config.programs.emacs.enable {
    home.packages = [hmConfig.services.emacs.package];

    services.emacs = {
      enable = true;
      package = emacs;
    };

    xdg.configFile."emacs/early-init.el".source = impurity.link ./config/early-init.el;
    xdg.configFile."emacs/init.el".source = impurity.link ./config/init.el;
  };
}

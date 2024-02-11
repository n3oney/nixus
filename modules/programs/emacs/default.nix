{
  inputs,
  config,
  pkgs,
  lib,
  hmConfig,
  ...
}: let
  emacsPkgs = inputs.emacs-overlay.packages.${pkgs.system};

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

  emacs =
    (pkgs.emacsPackagesFor
      (
        (pkgs.emacs29-pgtk.override {
          withNativeCompilation = true;
        })
        .overrideAttrs (old: {
          postFixup =
            (old.postFixup or "")
            + ''
              for program in $out/bin/*; do
                 if [ -x "$program" ]; then  # Check if the file is executable
                   wrapProgram $program \
                     --prefix PATH : "${lib.makeBinPath (builtins.attrValues {
                inherit (pkgs) nil alejandra rust-analyzer;
              })}"
                 fi
               done
            '';
        })
      ))
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
in {
  options.programs.emacs.enable = lib.mkEnableOption "emacs";

  config.hm = lib.mkIf config.programs.emacs.enable {
    home.packages = [hmConfig.services.emacs.package];

    services.emacs = {
      enable = true;
      package = emacs;
    };
  };
}

{
  impurity,
  config,
  pkgs,
  lib,
  hmConfig,
  ...
}: let
  tree-sitter-css-in-js = pkgs.stdenv.mkDerivation (let
    location = null;
    generate = false;
  in rec {
    pname = "tree-sitter-css-in-js-grammar";
    version = "2023-11-21";

    src = pkgs.fetchFromGitHub {
      repo = "tree-sitter-css-in-js";
      owner = "orzechowskid";
      rev = "0ce23b235748a31b288dd3024624d40413e3f6b8";
      hash = "sha256-PbBFuSE/RBZ7VHGxo2KVyY/ZNpxkw0+vv0zi1+J5MTc=";
    };

    nativeBuildInputs = lib.optionals generate [pkgs.nodejs pkgs.tree-sitter];

    CFLAGS = ["-Isrc" "-O2"];
    CXXFLAGS = ["-Isrc" "-O2"];

    stripDebugList = ["parser"];

    configurePhase =
      lib.optionalString (location != null) ''
        cd ${location}
      ''
      + lib.optionalString generate ''
        tree-sitter generate
      '';

    # When both scanner.{c,cc} exist, we should not link both since they may be the same but in
    # different languages. Just randomly prefer C++ if that happens.
    buildPhase = ''
      runHook preBuild
      if [[ -e src/scanner.cc ]]; then
        $CXX -fPIC -c src/scanner.cc -o scanner.o $CXXFLAGS
      elif [[ -e src/scanner.c ]]; then
        $CC -fPIC -c src/scanner.c -o scanner.o $CFLAGS
      fi
      $CC -fPIC -c src/parser.c -o parser.o $CFLAGS
      rm -rf parser
      $CXX -shared -o parser *.o
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir $out
      mv parser $out/
      if [[ -d queries ]]; then
        cp -r queries $out
      fi

      mkdir -p $out/share/emacs/site-lisp/elpa/${pname}-${version}/

      cp $src/css-in-js-mode.el $out/share/emacs/site-lisp/elpa/${pname}-${version}/

      runHook postInstall
    '';
  });

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
      tree-sitter-css-in-js = tree-sitter-css-in-js;
    };

  emacsWithoutPath =
    (pkgs.emacsPackagesFor
      (pkgs.emacs29-pgtk.override {
        withNativeCompilation = true;
      }))
    .emacsWithPackages
    (
      epkgs: let
        tsx-mode = epkgs.trivialBuild rec {
          pname = "tsx-mode";
          version = "2023-10-05";

          src = pkgs.fetchFromGitHub {
            owner = "orzechowskid";
            repo = "tsx-mode.el";
            rev = "e7fc4a3302bfc7e4affe51684e2c855c64093996";
            hash = "sha256-zchJEMkfTmJAExeOOBdQHGEe7VzNXg2Qv1X+Z2CdPm0=";
          };

          propagatedUserEnvPkgs = [
            epkgs.coverlay
            epkgs.origami
            tree-sitter-css-in-js
            pkgs.tree-sitter

            (epkgs.treesit-grammars.with-grammars (p: [p.tree-sitter-typescript p.tree-sitter-tsx]))
          ];

          buildInputs = propagatedUserEnvPkgs;
        };
      in
        builtins.attrValues {
          inherit
            (epkgs)
            affe
            avy
            better-jumper
            company
            crux
            catppuccin-theme
            consult
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
            typescript-mode
            undo-tree
            use-package
            vertico
            which-key
            ws-butler
            ;
          ts-grammars =
            epkgs.treesit-grammars.with-grammars ts-parsers;
          tsx-mode = tsx-mode;
          tree-sitter-css-in-js = tree-sitter-css-in-js;
        }
    );

  emacs = let
    packages = builtins.attrValues {
      inherit (pkgs) nil alejandra rust-analyzer rustfmt ripgrep prettierd;
      inherit (pkgs.nodePackages) typescript-language-server typescript;
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

    xdg.configFile."emacs".source = hmConfig.lib.file.mkOutOfStoreSymlink "/home/neoney/nixus/modules/programs/emacs/config";

    # xdg.configFile."emacs/early-init.el".source = impurity.link ./config/early-init.el;
    # xdg.configFile."emacs/init.el".source = impurity.link ./config/init.el;
  };
}

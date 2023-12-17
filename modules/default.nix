{lib, ...}: let
  inherit (lib) attrNames optional hasSuffix;
  inherit (builtins) elem readDir foldl';

  foldlAttrs = f: init: set:
    foldl'
    (acc: name: f acc name set.${name})
    init
    (attrNames set);

  concatPaths = path1: path2: (toString path1) + "/" + (toString path2);
  getModules = ignoreDefault: path: let
    files = readDir path;
    isModuleDirectory = !ignoreDefault && elem "default.nix" (attrNames files);
  in
    if isModuleDirectory
    then [(concatPaths path "default.nix")]
    else
      foldlAttrs (
        acc: name: type:
          acc
          ++ (
            if (type == "regular")
            then optional (name != "default.nix" && hasSuffix "nix" name) (concatPaths path name)
            else getModules false (concatPaths path name)
          )
      ) []
      files;
in {
  imports = getModules true ./.;
}

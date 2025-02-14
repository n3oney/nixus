attrs: let
  processEntry = key: value:
    if builtins.isList value
    then
      map (v: "${key} = ${
        if v == null || v == ""
        then ""
        else toString v
      }")
      value
    else let
      valStr =
        if value == null || value == ""
        then ""
        else toString value;
    in ["${key} = ${valStr}"];
  lines = builtins.concatLists (builtins.attrValues (builtins.mapAttrs processEntry attrs));
in
  builtins.concatStringsSep "\n" lines

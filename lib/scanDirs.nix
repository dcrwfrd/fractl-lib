{ lib }:

let
  inherit (lib)
    hasPrefix
    filterAttrs
    attrNames
    pathExists;

in 
  path:
    let
      isConfigDir = name: type: type == "directory" && !(hasPrefix "." name) && name != "default";
    in
      if pathExists path 
      then attrNames (filterAttrs isConfigDir (builtins.readDir path)) 
      else [ ]

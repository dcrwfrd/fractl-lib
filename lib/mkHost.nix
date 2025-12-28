{ inputs, lib, flakeCfg, mkUser, scanDirs }:

let
  inherit (lib) listToAttrs;
  inherit (inputs) nixpkgs import-tree;

  hosts = scanDirs flakeCfg.paths.host;
  specialArgs = flakeCfg.specialArgs // flakeCfg.extraSpecialArgs;
  overlays = [ (import flakeCfg.paths.overlay { inherit inputs; }) ];
  extraModules = map (path: import-tree path) flakeCfg.paths.extraModulePaths;

  mkNixosConfiguration =
    host:
    nixpkgs.lib.nixosSystem {
      system = flakeCfg.system;
      inherit specialArgs;

      modules = [
        (import-tree flakeCfg.paths.nixosModules)
        (import-tree "${flakeCfg.paths.host}/${host}")
        inputs.home-manager.nixosModules.home-manager
        mkUser

        {
          nixpkgs.overlays = overlays;
          networking.hostName = "${flakeCfg.networkName}-${host}";
        }
      ] ++ extraModules;
    };

  mkHost = host: {
    name = "${flakeCfg.networkName}-${host}";
    value = mkNixosConfiguration host;
  };

in
listToAttrs (map mkHost hosts)

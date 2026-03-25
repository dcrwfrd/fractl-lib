{ inputs, lib, flakeCfg, mkUser, scanDirs }:

let
  inherit (lib) listToAttrs;
  inherit (inputs) nixpkgs import-tree;

  hosts = scanDirs flakeCfg.paths.hosts;
  specialArgs = flakeCfg.specialArgs // flakeCfg.extraSpecialArgs;
  overlays = [ (import flakeCfg.paths.overlays { inherit inputs; }) ];

  mkNixosConfiguration =
    host:
    nixpkgs.lib.nixosSystem {
      system = flakeCfg.system;
      inherit specialArgs;

      modules = [
        (import-tree flakeCfg.paths.nixosModules)
        (import-tree "${flakeCfg.paths.hosts}/${host}")
        inputs.home-manager.nixosModules.home-manager
        mkUser

        {
          nixpkgs.overlays = overlays;
          networking.hostName = "${host}";
        }
      ];
    };

  mkHost = host: {
    name = "${host}";
    value = mkNixosConfiguration host;
  };

in
listToAttrs (map mkHost hosts)

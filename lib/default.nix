{ self, inputs, lib, config, ... }:

{
  options = {
    flake.fractl = {
      networkName = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        example = "fractl";
      };

      system = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
      };

      paths = {
        users = lib.mkOption {
          type = lib.types.path;
          default = "${self}/config/users";
        };

        hosts = lib.mkOption {
          type = lib.types.path;
          default = "${self}/config/hosts";
        };

        modules = lib.mkOption {
          type = lib.types.path;
          default = "${self}/modules";
        };

        home-manager = lib.mkOption {
          type = lib.types.path;
          default = "${self}/home-manager";
        };

        overlays = lib.mkOption {
          type = lib.types.path;
          default = "${self}/overlays";
        };

        extraModulePaths = lib.mkOption {
          type = lib.types.listOf lib.types.path;
          default = [ ];
          example = [ ./extra-modules ./company-modules ];
        };
      };

      specialArgs = lib.mkOption {
        type = lib.types.attrs;
        default = { inherit inputs; };
      };

      extraSpecialArgs = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        example = { myLib = import ./myLib.nix; };
      };

      homeManager = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };

        useGlobalPkgs = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };

        useUserPackages = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };
  };

  config = let
    flakeCfg = config.flake.fractl;
    scanDirs = import ./scanDirs.nix { inherit lib; };
    mkUser = import ./mkUser.nix { inherit inputs lib flakeCfg scanDirs; };
    mkNixosConfigurations = import ./mkHost.nix { inherit inputs lib flakeCfg mkUser scanDirs; };


  in {
    flake = {
      nixosConfigurations = mkNixosConfigurations;
      
      overlays = {
        default = import "${self}/${flakeCfg.paths.overlays}" { inherit inputs; };
      };
    };
  };
}

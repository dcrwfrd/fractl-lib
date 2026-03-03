{ self, inputs, lib, config, ... }:

{
  options = {
    flake.fractal = {
      networkName = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        example = "home";
      };

      system = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
      };

      paths = {
        users = lib.mkOption {
          type = lib.types.path;
          default = "${self}/configs/users";
        };

        hosts = lib.mkOption {
          type = lib.types.path;
          default = "${self}/configs/hosts";
        };

        nixosModules = lib.mkOption {
          type = lib.types.path;
          default = "${self}/modules/nixos";
        };

        homeModules = lib.mkOption {
          type = lib.types.path;
          default = "${self}/modules/home-manager";
        };

        overlays = lib.mkOption {
          type = lib.types.path;
          default = "${self}/overlays";
        };

        extraModulePaths = lib.mkOption {
          type = lib.types.path;
          default = "${self}/modules/extra";
          example = "${self}/extraModules";
        };
      };

      specialArgs = lib.mkOption {
        type = lib.types.attrs;
        default = { inherit inputs; };
      };

      extraSpecialArgs = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        example = { example = import ./example.nix; };
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
    flakeCfg = config.flake.fractal;
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

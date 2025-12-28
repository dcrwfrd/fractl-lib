{ inputs, lib, flakeCfg, scanDirs, }: { config, pkgs, ... }:

let
  inherit (lib)
    mkOption
    mkIf
    types
    genAttrs;

  cfg = config.nixos.users;
  users = scanDirs flakeCfg.paths.users;

in
{
  options.nixos.users = {
    primaryUser = mkOption {
      type = types.nullOr (types.enum users);
      default = null;
    };

    enabledUsers = mkOption {
      type = types.listOf (types.enum users);
      default = [ ];
    };
  };

  config = mkIf (cfg.enabledUsers != [ ]) {
    users.users = genAttrs cfg.enabledUsers (user: {
      isNormalUser = true;
      shell = pkgs.zsh;
    });

    home-manager = mkIf flakeCfg.homeManager.enable {
      extraSpecialArgs = { inherit inputs; };
      useGlobalPkgs = flakeCfg.homeManager.useGlobalPkgs;
      useUserPackages = flakeCfg.homeManager.useUserPackages;

      users = genAttrs cfg.enabledUsers (user: {
        imports = [
          (inputs.import-tree "${flakeCfg.paths.home-manager}")
          (inputs.import-tree "${flakeCfg.paths.users}/${user}")
        ];

        programs.home-manager.enable = true;

        home = {
          username = user;
          homeDirectory = "/home/${user}";
          stateVersion = "25.11";
        };
      });
    };
  };
}

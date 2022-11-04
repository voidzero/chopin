# vim: ts=2 sw=2 ai et si sta fdm=marker
{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
  mkHMUser = {userConfig, username}:
    home-manager.lib.homeManagerConfiguration {
      inherit system username pkgs;
      stateVersion = "22.05";
      configuration =
      let
        trySettings = tryEval (fromJSON (readFile /etc/hmsystemdata.json));
        machineData = if trySettings.success then trySettings.value else {};

        machineModule = { pkgs, config, lib, ... }: {
          options.machineData = lib.mkOption {
            default = {};
            description = "Settings passed from nixos system configuration. If not present will be empty";
          };

          config.machineData = machineData;
        };
      in {
        markvd = userConfig;

        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;

        systemd.user.startServices = true;
        home.stateVersion = "22.05";
        home.username = username;
        home.homeDirectory = "/home/${username}";

        imports = [ ../modules/users machineModule ];
      };
      homeDirectory = "/home/${username}";
    };

  mkSystemUser = { name, groups, uid, shell, ... }:
  {
    users.users."${name}" = {
      name = name;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = groups;
      uid = uid;
      initialPassword = "HerroWorld"; # yikes
      shell = shell;
    };
  };
}

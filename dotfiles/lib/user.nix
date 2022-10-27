# vim: ts=2 sw=2 ai et si sta fdm=marker
{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
  mkHMUser = { # To be completed later };

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

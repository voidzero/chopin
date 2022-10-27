{ config, pkgs, ... }:

let
#  unstable = import
#    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
#    # reuse the current configuration
#    { config = config.nixpkgs.config; };
  unstable = import <nixpkgs-unstable> { config = { allowUnfree = true; }; };
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "markvd";
  home.homeDirectory = "/home/markvd";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
  home.enableNixpkgsReleaseCheck = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;

  home.packages = with pkgs; [
    pkgs.htop
    pkgs.fortune
    tdesktop
    thunderbird
    unstable.vivaldi
    xclip
    parcellite
  ];

  home.shellAliases = {
    sudol = "sudo login -f root";
  };
}

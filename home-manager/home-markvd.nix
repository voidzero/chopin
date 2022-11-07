# vim: ts=2 sw=2 ai et si sta fdm=marker

{ inputs, lib, config, pkgs, ... }: 
{
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  home = {
    username = "markvd";
    homeDirectory = "/home/markvd";
    stateVersion = "22.05";
    enableNixpkgsReleaseCheck = true;
    packages = with pkgs; [
      betterdiscordctl
      discord
      htop
      parcellite
      remmina
      tdesktop
      terminus-nerdfont
      terminus_font
      terminus_font_ttf
      thunderbird
      tig
      vivaldi-unstable
      xclip
    ];
    shellAliases = {
      sudol = "sudo login -f root";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

}

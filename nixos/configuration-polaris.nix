# vim: ts=2 sw=2 ai et si sta fdm=marker

{ config, pkgs, ... }:

let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./zfs.nix
       <nixpkgs/nixos/modules/profiles/hardened.nix>
      #<home-manager/nixos>
    ];

  # Boot  {{{
  #boot.loader.grub.useOSProber = true;
  #boot.kernelPackages = pkgs.linuxPackages_5_15_hardened;
  boot.kernelModules = [
    "tcp_bbr"
    "tcp_htcp"
    "tcp_yeah"
  ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "yeah";
    "kernel.pid_max" = 4194304;
    "kernel.panic" = 3;
    "net.core.default_qdisc" = "fq_codel";
    "kernel.sysrq" = 1;
    "net.ipv4.ip_default_ttl" = 97;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_syn_retries" = 3;
    "net.ipv4.tcp_synack_retries" = 4;
    "net.ipv4.tcp_orphan_retries" = 1;
    "net.ipv4.ip_local_port_range" = "4096 65499";
  };

  # }}}

  # Base networking  {{{
  networking.hostName = "nixos-polaris";
  networking.domain = "polaris.ula";
  networking.search = [ "ula" ];
  networking.resolvconf.enable = true;
  networking.dhcpcd.enable = false;

  # Enable networking
  # networking.networkmanager.enable = true;

  networking.usePredictableInterfaceNames = true;
  networking.enableIPv6 = true;

  networking.interfaces.ens3.ipv4.addresses = [ {
    address = "10.30.1.37";
    prefixLength = 27;
  } ];

  networking.defaultGateway = {
    address = "10.30.1.33";
    interface = "ens3";
  };

  networking.interfaces.ens3.ipv6.addresses = [ {
    address = "fd05:eb97:833:1e11::25";
    prefixLength = 64;
  } ];

  networking.defaultGateway6 = {
    address = "fd05:eb97:833:1e11::1";
    interface = "ens3";
  };

  networking.nameservers = [
    "10.30.1.1"
    "10.30.0.1"
    "fd05:eb97:833:1e10::1"
    "fd05:eb97:833:1e00::1"
  ];

  networking.resolvconf.dnsExtensionMechanism = true;
  networking.resolvconf.dnsSingleRequest = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.enable = false;

  # }}}

  # Base system  {{{
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.utf8";
    LC_IDENTIFICATION = "nl_NL.utf8";
    LC_MEASUREMENT = "nl_NL.utf8";
    LC_MONETARY = "nl_NL.utf8";
    LC_NAME = "nl_NL.utf8";
    LC_NUMERIC = "nl_NL.utf8";
    LC_PAPER = "nl_NL.utf8";
    LC_TELEPHONE = "nl_NL.utf8";
    LC_TIME = "nl_NL.utf8";
  };

  # Configure console keymap
  #console.keyMap = "dvorak";


  system.autoUpgrade.enable = false;
  system.autoUpgrade.allowReboot = false;

  # see: https://github.com/NixOS/nixpkgs/blob/nixos-22.05/nixos/modules/security/sudo.nix
  security.sudo.wheelNeedsPassword = false;
  security.sudo.execWheelOnly = true;

  # }}}

  # Groups and users {{{

  # Attention: this will cause all users and groups created with 'useradd' and
  # 'groupadd' to disappear on system activation. Beware.
  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;

  users.extraGroups = {
  };
    
  users.users.root = {
    shell = pkgs.zsh;
    hashedPassword = "$5$VKX9pCBx95O0eaTX$cE453jGLxTq/0ZyuVOnwBZaG5e.D4O4hFfFcwdDV9Y0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPGpP6D18IrdyOw35j1vfWHe1dCWWBLWFrJZg2OEBHj markvd@nixos-vmware_221027"
    ];
  };

  users.users.markvd = {
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    description = "Mark van Dijk";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$5$ZN2DjQcVlPo2RO6o$d5Z/EmjM.cpdybh/giCKY9oIAc1fVCgaaCudbNxzqQD";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1GhQD+fh2ozjyhOjqgQBKokgghh47CJCqcl4DDIMQ7 markvd@athena 140503"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlhfg/CA1RRXxz7/ftD6sa+35E9T2DSkiRKXjVDOPru markvd@backspace 140503"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCPDNvVIHMZcS1QFQMmPPTbe9UUhkD0IvGVwrm9obMd17+fxTjXlw/6Kzvu5u6sI8ORQrqwMilShKGH3O6YlBJU= 200612_totalcmd"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPGpP6D18IrdyOw35j1vfWHe1dCWWBLWFrJZg2OEBHj markvd@nixos-vmware_221027"
    ];
    #packages = with pkgs; [ firefox ];
  };

  #programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  #environment.shells = with pkgs; [ zsh ];

  # }}}

  # X-Server  {{{
  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.autorun = false;

  # Enable the Cinnamon Desktop Environment.
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  #services.xserver = {
  #  layout = "us";
  #  xkbVariant = "dvorak";
  #};

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = false;
  #services.xserver.displayManager.autoLogin.user = "markvd";
  #services.x2goserver = {
  #  enable = true;
  #  settings = {
  #    superenicer.enable = true;
  #    superenicer.idle-nice-level = 19;
  #    telekinesis.enable = false;
  #  };
  #  nxagentDefaultOptions = [
  #    "-extension GLX"
  #    "-nolisten tcp"
  #  ];
  #};
  # }}}

  # Nixpkgs  {{{

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow experimental comments
  nix.extraOptions = "extra-experimental-features = nix-command flakes";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Utilities
    file
    freshfetch
    git
    mc
    ripgrep
    rsync
    tmux
    vim_configurable
    wget

    # packers
    lz4
    lzop
    p7zip
    unzip
    zip

    # zsh stuff
    zsh
    oh-my-zsh
    zsh-git-prompt
    zsh-nix-shell
    zsh-vi-mode
    zsh-completions
    zsh-command-time
    zsh-powerlevel10k
    zsh-fast-syntax-highlighting
    nix-zsh-completions
  ];

  # Write all installed packages to /etc/current-system-packages
  #environment.etc."current-system-packages".text =
  #let
  #  packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
  #  sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
  #  formatted = builtins.concatStringsSep "\n" sortedUnique;
  #in
  #  formatted;

  # }}}

  # Services   {{{

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  # Enable mlocate
  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    interval = "hourly";
  };
  services.locate.localuser = null;

  # }}}

  # Programs  {{{

  programs.vim.package = pkgs.vim_configurable;
  programs.vim.defaultEditor = true;

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    loginShellInit = "[[ -r ~/.hush_login ]] || freshfetch;";
    interactiveShellInit = ''
      # Add 'cdr' function
      autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    '';
    ohMyZsh = {
      enable = true;
      theme = "gentoo";
      customPkgs = with pkgs; [
        zsh-git-prompt
        zsh-nix-shell
        zsh-vi-mode
        zsh-completions
        zsh-command-time
        zsh-powerlevel10k
        zsh-fast-syntax-highlighting
        nix-zsh-completions
      ];
      #plugins = [
      #  {
      #    name = "psgrep";
      #    src = pkgs.fetchFromGitHub {
      #      owner  = "voidzero";
      #      repo   = "omz-plugin-psgrep";
      #      rev    = "master";
      #      sha256 = "0000000000000000000000000000000000000000000000000000";
      #    };
      #  }
      #];
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        #"regexp"
        #"cursor"
        "root"
      ];
      patterns = {
        "rm -rf *" = "fg=white,bold,bg=red";
      };
    };
  };

  environment.shellAliases = {
    "1ssh" = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
    "flinksync" = "rsync -ahHAXE --info=stats2,flist2,misc2,progress2 --numeric-ids";
    "flinkdelsync" = "rsync -ahHAXE --info=stats2,flist2,misc2,progress2 --delete-delay --delay-updates --numeric-ids";
    "vim" = "vim -p";
  };

  # }}}

}

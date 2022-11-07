# vim: ts=2 sw=2 ai et si sta fdm=marker

{ inputs, lib, config, pkgs, ... }: {

  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware), use something like:
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # It's strongly recommended you take a look at
    # https://github.com/nixos/nixos-hardware
    # and import modules relevant to your hardware.

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # You can also split up your configuration and import pieces of it here.
  ];

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # Boot  {{{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
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

  virtualisation.vmware.guest.enable = true;

  # }}}

  # Base networking  {{{
  networking.hostName = "nixos-vmware";
  networking.domain = "loreto.apu.ula";
  networking.search = [ "ula" ];

  # Enable networking
  networking.networkmanager.enable = true;

  networking.usePredictableInterfaceNames = true;
  networking.enableIPv6 = false;
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
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

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
    ];
    #packages = with pkgs; [ firefox ];
  };

  #programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  #environment.shells = with pkgs; [ zsh ];

  # }}}

  # X-Server  {{{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "compose:rctrl,eurosign:5,terminate:ctrl_alt_bksp";
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "markvd";
  # }}}

  # Nixpkgs  {{{

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

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

    # system
    open-vm-tools

    # packers
    lz4
    lzop
    p7zip
    unzip
    zip

    # vim stuff
    vimPlugins.terminus

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

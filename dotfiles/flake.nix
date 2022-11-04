# vim: ts=2 sw=2 ai et si sta fdm=marker
{
  description = "System config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
  let
    inherit (nixpkgs) lib;

    util = import ./lib {
      inherit system pkgs home-manager lib; overlays = (pkgs.overlays);
    };

    inherit (util) user;
    inherit (util) host;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [];
    };

    system = "x86_64-linux";
  in {
    homeManagerConfigurations = {
      markvd = user.mkHMUser {
        # ...
      };
    };

    nixosConfigurations = {
      vmware = host.mkHost {
        name = "nixos-vmware";
        NICs = [ "ens33" ];
        kernelPackage = pkgs.linuxPackages;
        initrdMods = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];
        kernelMods = [];
        kernelParams = [];
        systemConfig = {
          # foobar
        };
        users = [{
          name = "markvd";
          groups = [ "wheel" "networkmanager" "users" ];
          uid = 1000;
          shell = pkgs.zsh;
        }];
        cpuCores = 4;
      };
    };
  };
}


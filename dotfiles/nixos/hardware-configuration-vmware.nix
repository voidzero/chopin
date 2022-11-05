# vim: ts=2 sw=2 ai et si sta fdm=marker
{ config, lib, ... }:
{
  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a867e67b-9340-4246-b369-a56a2cb0392b";
    fsType = "ext4";
  };
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = "x86_64-linux";
}

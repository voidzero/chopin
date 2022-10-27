# vim: ts=2 sw=2 ai et si sta fdm=marker
# dotfiles/lib/default.nix
{ pkgs, home-manager, system, lib, overlays, ... }:
rec {
  user = import ./user.nix { inherit pkgs home-manager lib system overlays; };
  host = import ./host.nix { inherit system pkgs home-manager lib user; };
}

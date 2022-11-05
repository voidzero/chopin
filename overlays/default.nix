# vim: ts=2 sw=2 ai et si sta fdm=marker
# This file defines two overlays and composes them
{ inputs, ... }:
let
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
  unstable-overrides = final: prev:
  let pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${final.system};
  in {
    vivaldi-unstable = pkgs-unstable.vivaldi;
  };
in
inputs.nixpkgs.lib.composeManyExtensions [ additions modifications unstable-overrides ]

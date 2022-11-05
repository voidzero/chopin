{ overlays, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}

# vim: ts=2 sw=2 ai et si sta fdm=marker
{ overlays, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
    # Overlays is an attrset, convert to a list
    overlays = builtins.attrValues overlays;
  };
}

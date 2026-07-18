{
  lib,
  callPackages,
  varnish80,
}:
{
  varnish80Packages = lib.recurseIntoAttrs rec {
    modules = (callPackages ./modules.nix { inherit varnish; }).modules27;
    varnish = varnish80;
  };
}

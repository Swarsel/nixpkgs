{
  callPackage,
}:
{
  modules = callPackage ./modules.nix { };
  python-path = callPackage ./python-path.nix { };
}

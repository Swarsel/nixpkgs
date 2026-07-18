{ callPackage, ccextractor }:

{
  node = callPackage ./node.nix { };
  server = callPackage ./server.nix { inherit ccextractor; };
}

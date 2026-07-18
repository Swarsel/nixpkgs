{
  lib,
  fetchFromGitHub,
  callPackage,
  zig_0_14,
}:
let
  versions = [
    {
      version = "0-unstable-2025-03-05";

      src = fetchFromGitHub {
        owner = "Vexu";
        repo = "arocc";
        rev = "8c6bab43ba351fc045a1d262d8a8da4a11215e37";
        hash = "sha256-J5Cj9UMwAMwH2JGby13FIKl5Qbj4N4XpSSY7zL21aoY=";
      };

      zig = zig_0_14;
    }
  ];

  mkPackage =
    {
      src,
      version,
      zig,
    }:
    callPackage ./package.nix { inherit zig version src; };

  pkgsList = lib.map mkPackage versions;

  pkgsAttrsUnwrapped = lib.listToAttrs (
    lib.map (pkg: lib.nameValuePair "${pkg.version}-unwrapped" pkg) pkgsList
  );
  pkgsAttrsWrapped = lib.listToAttrs (
    lib.map (pkg: lib.nameValuePair pkg.version pkg.wrapped) pkgsList
  );

  pkgsAttrs = pkgsAttrsWrapped // pkgsAttrsUnwrapped;
in
{
  latest = (lib.last pkgsList).wrapped;
  latest-unwrapped = lib.last pkgsList;
}
// pkgsAttrs

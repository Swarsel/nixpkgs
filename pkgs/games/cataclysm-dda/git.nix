{
  lib,
  fetchFromGitHub,
  attachPkgs,
  callPackage,
  pkgs,
  debug ? false,
  rev ? "b871679a2d54dbc6bf3e6566033fadd2dc651592",
  sha256 ? "sha256-t9R0QPky7zvjgGMq4kV8DdQFToJ/qngbJCw+8FlQztM=",
  tiles ? true,
  useXdgDir ? false,
  version ? "2024-12-11",
}:

let
  common = callPackage ./common.nix {
    inherit tiles debug useXdgDir;
  };

  self = common.overrideAttrs (common: rec {
    inherit version;
    pname = common.pname + "-git";

    src = fetchFromGitHub {
      inherit rev sha256;
      owner = "CleverRaven";
      repo = "Cataclysm-DDA";
    };

    patches = [
      # Unconditionally look for translation files in $out/share/locale
      ./locale-path-git.patch
    ];

    makeFlags = common.makeFlags ++ [
      "VERSION=git-${version}-${lib.substring 0 8 src.rev}"
    ];

    meta = common.meta // {
      maintainers = common.meta.maintainers ++ [ ];
    };
  });
in

attachPkgs pkgs self

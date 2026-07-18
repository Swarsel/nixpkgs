pkgargs@{
  lib,
  stdenv,
  gawk,
  haskellPackages,
  writeText,
}:
let
  generic-fetcher = import ./generic-fetcher.nix pkgargs;
in

args@{
  imageName,
  tag,
  repository ? "library",
  ...
}:

generic-fetcher (
  {
    fetcher = "hocker-config";
    name = "${repository}_${imageName}_${tag}-config.json";
    tag = "unused";
  }
  // args
)

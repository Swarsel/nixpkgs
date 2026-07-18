{ mkDerivation }:
mkDerivation {
  extraPaths = [
    "sys"
    "usr.bin/ktrace"
  ];

  path = "usr.bin/kdump";
}

{ mkDerivation }:
mkDerivation {
  extraPaths = [
    "sys/libkern"
    "sys/ufs"
  ];

  path = "lib/libufs";
}

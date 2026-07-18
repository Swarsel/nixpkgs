{
  lib,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  postInstall = ''
    mv $out/data/pkgconfig $out/lib/pkgconfig
  '';

  path = "lib/libusb";
  meta.platforms = lib.platforms.freebsd;
}

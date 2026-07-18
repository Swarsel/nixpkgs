{
  lib,
  libusb,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libusb
  ];

  path = "usr.sbin/usbconfig";
  meta.mainProgram = "usbconfig";
  meta.platforms = lib.platforms.freebsd;
}

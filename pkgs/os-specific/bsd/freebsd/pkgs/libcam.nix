{
  lib,
  libsbuf,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libsbuf
  ];

  MK_TESTS = "no";

  extraPaths = [
    "sys/cam"
    "sys/dev/nvme"
  ];

  path = "lib/libcam";
  meta.platforms = lib.platforms.freebsd;
}

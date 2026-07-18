{
  lib,
  libsbuf,
  libxo,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libxo
    libsbuf
  ];

  MK_TESTS = "no";
  path = "usr.bin/procstat";
  meta.mainProgram = "procstat";
  meta.platforms = lib.platforms.freebsd;
}

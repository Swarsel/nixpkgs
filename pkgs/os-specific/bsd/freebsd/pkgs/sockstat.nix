{
  libcapsicum,
  libcasper,
  libjail,
  libxo,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [
    libjail
    libxo
    libcasper
    libcapsicum
  ];

  MK_TESTS = "no";
  path = "usr.bin/sockstat";
  meta.mainProgram = "sockstat";
}

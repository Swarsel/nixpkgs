{
  libcapsicum,
  libcasper,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [
    libcasper
    libcapsicum
  ];

  path = "usr.bin/logger";
}

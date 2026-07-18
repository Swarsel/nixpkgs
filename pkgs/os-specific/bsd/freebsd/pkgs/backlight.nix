{
  libcapsicum,
  libcasper,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libcapsicum
    libcasper
  ];

  path = "usr.bin/backlight";
}

{
  libutil,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libutil
  ];

  path = "usr.bin/login";
  meta.mainProgram = "login";
}

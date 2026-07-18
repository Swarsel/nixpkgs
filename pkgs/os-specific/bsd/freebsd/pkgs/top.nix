{
  libjail,
  libncurses-tinfo,
  libsbuf,
  libutil,
  mkDerivation,
  ...
}:
mkDerivation {
  buildInputs = [
    libjail
    libncurses-tinfo
    libutil
    libsbuf
  ];

  path = "usr.bin/top";
}

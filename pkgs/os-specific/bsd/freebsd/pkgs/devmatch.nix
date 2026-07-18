{
  libdevinfo,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [
    libdevinfo
  ];

  path = "sbin/devmatch";
}

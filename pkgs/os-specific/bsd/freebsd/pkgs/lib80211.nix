{
  libbsdxml,
  libsbuf,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libsbuf
    libbsdxml
  ];

  clangFixup = true;

  installTargets = [
    "install"
    "installconfig"
  ];

  path = "lib/lib80211";
}

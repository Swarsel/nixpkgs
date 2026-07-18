{
  libdmtx,
  mkKdeDerivation,
  qrencode,
  qtdeclarative,
  qtmultimedia,
}:
mkKdeDerivation {
  pname = "prison";

  extraBuildInputs = [
    qtdeclarative
    qtmultimedia
    qrencode
    libdmtx
  ];
}

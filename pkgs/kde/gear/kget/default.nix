{
  libmms,
  mkKdeDerivation,
  qgpgme,
}:
mkKdeDerivation {
  pname = "kget";

  extraBuildInputs = [
    qgpgme
    libmms
  ];

  meta.mainProgram = "kget";
}

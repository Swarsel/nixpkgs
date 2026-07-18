{
  kirigami,
  kirigami-addons,
  mkKdeDerivation,
  qgpgme,
  qt5compat,
  qtdeclarative,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "mimetreeparser";

  extraBuildInputs = [
    qt5compat
    qtdeclarative
    qgpgme
  ];

  extraPropagatedBuildInputs = [
    kirigami
    kirigami-addons
    qtwebengine
  ];
}

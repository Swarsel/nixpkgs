{
  gettext,
  mkKdeDerivation,
  python3,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "ki18n";
  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [ python3 ];
  propagatedNativeBuildInputs = [ gettext ];
}

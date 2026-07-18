{
  kqtquickcharts,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "ktouch";
  extraBuildInputs = [ kqtquickcharts ];
}

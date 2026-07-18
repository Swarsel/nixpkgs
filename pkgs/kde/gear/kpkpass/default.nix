{
  mkKdeDerivation,
  qtdeclarative,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kpkpass";
  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [ shared-mime-info ];
}

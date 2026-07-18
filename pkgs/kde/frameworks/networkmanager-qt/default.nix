{
  mkKdeDerivation,
  networkmanager,
  pkg-config,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "networkmanager-qt";
  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [ pkg-config ];
  extraPropagatedBuildInputs = [ networkmanager ];
}

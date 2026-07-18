{
  mkKdeDerivation,
  qtdeclarative,
  qttools,
}:
mkKdeDerivation {
  pname = "kconfig";
  extraNativeBuildInputs = [ qttools ];
  extraPropagatedBuildInputs = [ qtdeclarative ];
}

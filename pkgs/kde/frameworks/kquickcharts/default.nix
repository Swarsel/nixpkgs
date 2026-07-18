{
  kirigami,
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kquickcharts";
  extraBuildInputs = [ qtdeclarative ];
  extraPropagatedBuildInputs = [ kirigami ];
}

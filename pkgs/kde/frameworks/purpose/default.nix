{
  kdeclarative,
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "purpose";
  extraBuildInputs = [ qtdeclarative ];

  extraPropagatedBuildInputs = [
    kdeclarative
  ];
}

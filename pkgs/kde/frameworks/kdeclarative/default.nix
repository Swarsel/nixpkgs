{
  mkKdeDerivation,
  qtdeclarative,
  spirv-tools,
}:
mkKdeDerivation {
  pname = "kdeclarative";
  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [ spirv-tools ];
}

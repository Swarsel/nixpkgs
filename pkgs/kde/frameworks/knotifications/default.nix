{
  libcanberra,
  mkKdeDerivation,
  qtdeclarative,
  qttools,
}:
mkKdeDerivation {
  pname = "knotifications";

  extraBuildInputs = [
    qtdeclarative
    libcanberra
  ];

  extraNativeBuildInputs = [ qttools ];
  hasPythonBindings = true;
}

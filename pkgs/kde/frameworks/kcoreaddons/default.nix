{
  mkKdeDerivation,
  qtdeclarative,
  qttools,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kcoreaddons";
  extraBuildInputs = [ qtdeclarative ];

  extraNativeBuildInputs = [
    qttools
    shared-mime-info
  ];

  hasPythonBindings = true;
}

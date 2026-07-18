{
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "kwidgetsaddons";
  extraNativeBuildInputs = [ qttools ];
  hasPythonBindings = true;
}

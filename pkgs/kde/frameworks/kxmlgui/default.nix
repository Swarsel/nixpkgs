{
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "kxmlgui";
  extraBuildInputs = [ qttools ];
  hasPythonBindings = true;
}

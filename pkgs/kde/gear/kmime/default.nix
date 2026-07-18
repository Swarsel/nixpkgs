{
  ki18n,
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "kmime";
  extraBuildInputs = [ ki18n ];
  extraNativeBuildInputs = [ qttools ];
}

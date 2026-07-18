{
  avahi,
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "kdnssd";
  extraBuildInputs = [ avahi ];
  extraNativeBuildInputs = [ qttools ];
}

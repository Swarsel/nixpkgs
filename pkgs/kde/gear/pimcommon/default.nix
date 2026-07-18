{
  libxslt,
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "pimcommon";
  extraBuildInputs = [ qttools ];
  extraNativeBuildInputs = [ libxslt ];
}

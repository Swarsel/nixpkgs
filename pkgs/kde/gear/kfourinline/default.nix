{
  _7zz,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kfourinline";
  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ _7zz ];
}

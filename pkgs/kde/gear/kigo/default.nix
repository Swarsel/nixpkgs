{
  _7zz,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kigo";
  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kigo";
}

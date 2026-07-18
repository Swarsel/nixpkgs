{
  _7zz,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "bovo";
  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "bovo";
}

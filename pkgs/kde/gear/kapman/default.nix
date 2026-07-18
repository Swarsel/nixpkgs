{
  _7zz,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kapman";
  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kapman";
}

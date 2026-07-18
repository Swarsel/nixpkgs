{
  _7zz,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "picmi";
  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "picmi";
}

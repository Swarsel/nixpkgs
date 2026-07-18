{
  _7zz,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kjumpingcube";
  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kjumpingcube";
}

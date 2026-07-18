{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "knavalbattle";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "knavalbattle";
}

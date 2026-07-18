{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kdiamond";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kdiamond";
}

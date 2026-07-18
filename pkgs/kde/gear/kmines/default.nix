{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kmines";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kmines";
}

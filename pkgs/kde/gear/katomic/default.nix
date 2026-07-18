{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "katomic";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "katomic";
}

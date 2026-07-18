{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "bomber";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "bomber";
}

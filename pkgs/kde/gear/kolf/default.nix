{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kolf";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kolf";
}

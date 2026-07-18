{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kbreakout";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kbreakout";
}

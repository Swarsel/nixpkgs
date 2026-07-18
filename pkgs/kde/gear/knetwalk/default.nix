{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "knetwalk";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "knetwalk";
}

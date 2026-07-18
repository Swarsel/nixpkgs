{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kollision";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kollision";
}

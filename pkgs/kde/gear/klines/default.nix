{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "klines";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "klines";
}

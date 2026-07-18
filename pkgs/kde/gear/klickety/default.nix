{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "klickety";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "klickety";
}

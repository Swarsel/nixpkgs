{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kgoldrunner";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kgoldrunner";
}

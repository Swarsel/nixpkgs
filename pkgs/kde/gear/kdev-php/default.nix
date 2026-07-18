{
  kdevelop-pg-qt,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kdev-php";
  extraNativeBuildInputs = [ kdevelop-pg-qt ];
}

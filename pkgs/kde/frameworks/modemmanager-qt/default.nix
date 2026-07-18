{
  mkKdeDerivation,
  modemmanager,
  pkg-config,
}:
mkKdeDerivation {
  pname = "modemmanager-qt";
  extraNativeBuildInputs = [ pkg-config ];
  extraPropagatedBuildInputs = [ modemmanager ];
}

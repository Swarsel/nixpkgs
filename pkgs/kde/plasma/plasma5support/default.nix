{
  gpsd,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "plasma5support";
  extraBuildInputs = [ gpsd ];
  extraNativeBuildInputs = [ pkg-config ];
}

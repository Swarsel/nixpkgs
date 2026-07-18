{
  mkKdeDerivation,
  pkg-config,
  qtmultimedia,
}:
mkKdeDerivation {
  pname = "qrca";

  extraBuildInputs = [
    qtmultimedia
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

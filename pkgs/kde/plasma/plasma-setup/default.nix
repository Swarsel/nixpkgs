{
  mkKdeDerivation,
  pkg-config,
  plasma-nm,
  qtlocation,
}:
mkKdeDerivation {
  pname = "plasma-setup";

  extraBuildInputs = [
    qtlocation
    plasma-nm
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

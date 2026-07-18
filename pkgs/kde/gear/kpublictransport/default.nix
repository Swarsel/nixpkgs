{
  mkKdeDerivation,
  pkg-config,
  qtdeclarative,
  qtlocation,
}:
mkKdeDerivation {
  pname = "kpublictransport";

  extraBuildInputs = [
    qtdeclarative
    qtlocation
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

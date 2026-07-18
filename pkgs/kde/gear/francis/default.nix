{
  knotifications,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "francis";

  extraBuildInputs = [
    qtsvg
    knotifications
  ];
}

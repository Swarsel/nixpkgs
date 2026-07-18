{
  kcontacts,
  mkKdeDerivation,
  qtlocation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kongress";

  extraBuildInputs = [
    kcontacts
    qtsvg
    qtlocation
  ];
}

{
  kcoreaddons,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "union";

  extraBuildInputs = [
    kcoreaddons
  ];
}

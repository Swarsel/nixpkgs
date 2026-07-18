{
  boost,
  mkKdeDerivation,
  qgpgme,
  qt5compat,
}:
mkKdeDerivation {
  pname = "libkleo";

  extraBuildInputs = [
    qt5compat
    boost
  ];

  extraPropagatedBuildInputs = [ qgpgme ];
}

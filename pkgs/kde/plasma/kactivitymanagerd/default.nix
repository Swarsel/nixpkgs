{
  boost,
  mkKdeDerivation,
  qt5compat,
}:
mkKdeDerivation {
  pname = "kactivitymanagerd";

  extraBuildInputs = [
    qt5compat
    boost
  ];
}

{
  cyrus_sasl,
  mkKdeDerivation,
  qt5compat,
}:
mkKdeDerivation {
  pname = "ksmtp";

  extraBuildInputs = [
    qt5compat
    cyrus_sasl
  ];
}

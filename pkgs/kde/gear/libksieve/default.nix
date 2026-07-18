{
  cyrus_sasl,
  mkKdeDerivation,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "libksieve";

  extraBuildInputs = [
    qtwebengine
    cyrus_sasl
  ];
}

{
  cyrus_sasl,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kimap";
  extraBuildInputs = [ cyrus_sasl ];
}

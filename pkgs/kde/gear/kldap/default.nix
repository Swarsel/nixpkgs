{
  cyrus_sasl,
  mkKdeDerivation,
  openldap,
}:
mkKdeDerivation {
  pname = "kldap";

  extraBuildInputs = [
    cyrus_sasl
    openldap
  ];
}

{
  cyrus_sasl,
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "libkgapi";

  extraBuildInputs = [
    qttools
    cyrus_sasl
  ];
}

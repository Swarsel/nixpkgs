{
  mkDerivation,
  openssl,
}:
mkDerivation {
  buildInputs = [
    openssl
  ];

  MK_TESTS = "no";
  path = "lib/libradius";
}

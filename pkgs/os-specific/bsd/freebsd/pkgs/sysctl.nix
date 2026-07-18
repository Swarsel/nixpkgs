{
  libjail,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libjail
  ];

  MK_TESTS = "no";
  path = "sbin/sysctl";
}

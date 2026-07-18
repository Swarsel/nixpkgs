{
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  MK_TESTS = "no";
  path = "usr.bin/sort";
  meta.mainProgram = "sort";
}

{
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  MK_TESTS = "no";
  path = "usr.bin/env";
  meta.mainProgram = "env";
}

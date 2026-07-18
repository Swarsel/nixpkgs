{
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  path = "usr.sbin/powerd";
  meta.mainProgram = "powerd";
}

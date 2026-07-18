{
  lib,
  libbsddialog,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libbsddialog
  ];

  path = "usr.sbin/kbdmap";
  meta.mainProgram = "kbdmap";
  meta.platforms = lib.platforms.freebsd;
}

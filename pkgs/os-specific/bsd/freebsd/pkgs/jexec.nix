{
  lib,
  libjail,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libjail
  ];

  path = "usr.sbin/jexec";
  meta.mainProgram = "jexec";
  meta.platforms = lib.platforms.freebsd;
}

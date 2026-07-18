{
  lib,
  libjail,
  libxo,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libjail
    libxo
  ];

  path = "usr.sbin/jls";
  meta.mainProgram = "jls";
  meta.platforms = lib.platforms.freebsd;
}

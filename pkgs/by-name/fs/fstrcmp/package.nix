{
  lib,
  stdenv,
  autoreconfHook,
  fetchzip,
  ghostscript,
  groff,
  libtool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fstrcmp";
  version = "0.7";

  src = fetchzip {
    url = "https://sourceforge.net/projects/fstrcmp/files/fstrcmp/${finalAttrs.version}/fstrcmp-${finalAttrs.version}.D001.tar.gz";
    sha256 = "0yg3y3k0wz50gmhgigfi2dx725w1gc8snb95ih7vpcnj6kabgz9a";
  };

  outputs = [
    "out"
    "dev"
    "doc"
    "man"
    "devman"
  ];

  patches = [ ./cross.patch ];

  nativeBuildInputs = [
    libtool
    ghostscript
    groff
    autoreconfHook
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Make fuzzy comparisons of strings and byte arrays";

    longDescription = ''
      The fstrcmp project provides a library that is used to make fuzzy
      comparisons of strings and byte arrays, including multi-byte character
      strings.
    '';

    homepage = "https://fstrcmp.sourceforge.net/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sephalon ];
    platforms = lib.platforms.unix;
    mainProgram = "fstrcmp";
    downloadPage = "https://sourceforge.net/projects/fstrcmp/";
  };
})

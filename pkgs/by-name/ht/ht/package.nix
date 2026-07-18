{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ht";
  version = "2.1.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/hte/ht-source/ht-${finalAttrs.version}.tar.bz2";
    sha256 = "0w2xnw3z9ws9qrdpb80q55h6ynhh3aziixcfn45x91bzrbifix9i";
  };

  patches = [ ./gcc7.patch ];

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    # Fails to build on -std=gnu23.
    "CFLAGS=-std=gnu17"
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-narrowing" ];
  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "File editor/viewer/analyzer for executables";
    homepage = "https://hte.sourceforge.net";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ht";
  };
})

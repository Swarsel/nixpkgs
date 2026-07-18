{
  lib,
  stdenv,
  fetchurl,
  allegro4,
  autoconf,
  automake,
}:

let
  allegro = allegro4;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "garden-of-coloured-lights";
  version = "1.0.9";

  src = fetchurl {
    url = "mirror://sourceforge/garden/${finalAttrs.version}/garden-${finalAttrs.version}.tar.gz";
    hash = "sha256-2vhzLCKaTMBPRgUUv/G6BRcfqtqeGVdccqUKkU8jUuM=";
  };

  nativeBuildInputs = [
    autoconf
    automake
  ];

  buildInputs = [ allegro ];
  # Workaround build failure on -fno-common toolchains:
  #   ld: main.o:src/main.c:58: multiple definition of
  #     `eclass'; eclass.o:src/eclass.c:21: first defined here
  env.NIX_CFLAGS_COMPILE = "-fcommon";

  prePatch = ''
    noInline='s/inline //'
    sed -e "$noInline" -i src/stuff.c
    sed -e "$noInline" -i src/stuff.h
  '';

  meta = {
    description = "Old-school vertical shoot-em-up / bullet hell";
    homepage = "https://sourceforge.net/projects/garden/";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    mainProgram = "garden";
  };
})

{
  lib,
  stdenv,
  SDL,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asap";
  version = "8.0.0";

  src = fetchzip {
    url = "mirror://sourceforge/project/asap/asap/${finalAttrs.version}/asap-${finalAttrs.version}.tar.gz";
    hash = "sha256-lk43jknsPndQ3KIvTgJBYYG2hhVaUrq5CGyuH0qXHeo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  buildInputs = [
    SDL
  ];

  buildFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    # Only targets that don't need cito transpiler
    "asapconv"
    "asap-sdl"
    "lib"
  ];

  enableParallelBuilding = true;

  installFlags = [
    "prefix=${placeholder "dev"}"
    "bindir=${placeholder "out"}/bin"
    "install-asapconv"
    "install-sdl"
    "install-lib"
  ];

  meta = {
    description = "Another Slight Atari Player";

    longDescription = ''
      ASAP (Another Slight Atari Player) plays and converts 8-bit Atari POKEY
      music (*.sap, *.cmc, *.mpt, *.rmt, *.tmc, ...) on modern computers and
      mobile devices.
    '';

    homepage = "https://asap.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.all;
    mainProgram = "asap-sdl";
  };
})

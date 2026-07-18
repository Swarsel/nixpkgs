{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_mixer,
  libGL,
  libGLU,
  libjpeg,
  plib,
}:
let
  version = "0.9.13";
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "crrcsim";

  src = fetchurl {
    url = "mirror://sourceforge/crrcsim/crrcsim-${finalAttrs.version}.tar.gz";
    sha256 = "abe59b35ebb4322f3c48e6aca57dbf27074282d4928d66c0caa40d7a97391698";
  };

  patches = [
    ./gcc6.patch
  ];

  buildInputs = [
    libGLU
    libGL
    SDL
    SDL_mixer
    plib
    libjpeg
  ];

  meta = {
    description = "Model-airplane flight simulator";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ raskin ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "crrcsim";
  };
})

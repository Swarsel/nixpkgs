{
  lib,
  stdenv,
  SDL,
  fetchzip,
  libsm,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "synaesthesia";
  version = "2.4";

  src = fetchzip {
    url = "https://logarithmic.net/pfh-files/synaesthesia/synaesthesia-${finalAttrs.version}.tar.gz";
    sha256 = "0nzsdxbah0shm2vlziaaw3ilzlizd3d35rridkpg40nfxmq84qnx";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    SDL
    libsm
  ];

  meta = {
    description = "Program for representing sounds visually";
    homepage = "https://logarithmic.net/pfh/synaesthesia";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "synaesthesia";
  };
})

{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  cmake,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hatari";
  version = "2.6.1";

  src = fetchFromGitLab {
    owner = "hatari";
    repo = "hatari";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hfSlpYwS6PcA4pqpYeFnOptN4hX7ZjLB8cu9cZ8pr7Y=";
    domain = "framagit.org";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    zlib
    SDL2
  ];

  # For pthread_cancel
  cmakeFlags = [ "-DCMAKE_EXE_LINKER_FLAGS=-lgcc_s" ];

  meta = {
    description = "Atari ST/STE/TT/Falcon emulator";
    homepage = "http://hatari.tuxfamily.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})

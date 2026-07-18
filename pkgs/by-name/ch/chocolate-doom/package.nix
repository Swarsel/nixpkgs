{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  SDL2_net,
  autoreconfHook,
  libpng,
  libsamplerate,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chocolate-doom";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "chocolate-doom";
    repo = "chocolate-doom";
    tag = "chocolate-doom-${finalAttrs.version}";
    hash = "sha256-wa4wxz70mxP41bNxWYD1EyxBGfyRoxEMPaoupvaK+XY=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    patchShebangs --build man/{simplecpp,docgen}
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    # for documentation
    python3
  ];

  buildInputs = [
    libpng
    libsamplerate
    SDL2
    SDL2_mixer
    SDL2_net
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Doom source port that accurately reproduces the experience of Doom as it was played in the 1990s";
    homepage = "https://www.chocolate-doom.org";
    changelog = "https://github.com/chocolate-doom/chocolate-doom/releases/tag/chocolate-doom-${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Gliczy ];
    platforms = lib.platforms.unix;
    mainProgram = "chocolate-doom";
  };
})

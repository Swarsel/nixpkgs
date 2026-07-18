{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  alsa-lib,
  cmake,
  fluidsynth,
  libGLU,
  libmad,
  libsndfile,
  libvorbis,
  libxmp,
  libzip,
  nix-update-script,
  portmidi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dsda-doom";
  version = "0.29.4";

  src = fetchFromGitHub {
    owner = "kraflab";
    repo = "dsda-doom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iZV8lsefEix0/iHXUGXJohSGxJDJC+eTijGVkOrwK0Q=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    alsa-lib
    fluidsynth
    libGLU
    libmad
    libsndfile
    libvorbis
    libxmp
    libzip
    portmidi
    SDL2
    SDL2_image
    SDL2_mixer
  ];

  sourceRoot = "${finalAttrs.src.name}/prboom2";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advanced Doom source port with a focus on speedrunning, successor of PrBoom+";
    homepage = "https://github.com/kraflab/dsda-doom";
    changelog = "https://github.com/kraflab/dsda-doom/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Gliczy ];
    platforms = lib.platforms.linux;
    mainProgram = "dsda-doom";
  };
})

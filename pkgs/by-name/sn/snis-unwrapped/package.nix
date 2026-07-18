{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-utils,
  coreutils,
  curlMinimal,
  espeak-classic,
  glew,
  libbsd,
  libopus,
  libpng,
  libvorbis,
  libx11,
  libxcrypt-legacy,
  lua5_2,
  makeWrapper,
  nix-update-script,
  openscad,
  openssl,
  picotts,
  pkg-config,
  portaudio,
  sdl2-compat,
  sox,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snis";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "smcameron";
    repo = "space-nerds-in-space";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H6ZeZOeKy8Z5HGicQs9CmjR2tDzD8AGvLr75Xx0YkAg=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "OPUSARCHIVE=libopus.a" "OPUSARCHIVE=" \
      --replace-fail "-I./opus-1.3.1/include" "-I${libopus.dev}/include/opus"
    substituteInPlace snis_text_to_speech.sh \
      --replace-fail "pico2wave" "${sox}/bin/pico2wave" \
      --replace-fail "espeak" "${espeak-classic}/bin/espeak" \
      --replace-fail "aplay" "${alsa-utils}/bin/aplay" \
      --replace-fail "play" "${sox}/bin/play" \
      --replace-fail "/bin/rm" "${coreutils}/bin/rm"
  '';

  nativeBuildInputs = [
    pkg-config
    openscad
    makeWrapper
  ];

  buildInputs = [
    coreutils
    portaudio
    libbsd
    libpng
    libvorbis
    libx11
    sdl2-compat
    lua5_2
    glew
    openssl
    picotts
    sox
    alsa-utils
    libopus
    libxcrypt-legacy
    curlMinimal
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  buildFlags = [
    "all"
    "models"
  ];

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Space Nerds In Space, a multi-player spaceship bridge simulator";
    homepage = "https://smcameron.github.io/space-nerds-in-space/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pentane ];
    platforms = lib.platforms.linux;
    mainProgram = "snis_launcher";
  };
})

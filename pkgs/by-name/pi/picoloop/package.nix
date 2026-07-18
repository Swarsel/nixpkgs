{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  alsa-lib,
  libjack2,
  libpulseaudio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "picoloop";
  version = "0.77e";

  src = fetchFromGitHub {
    owner = "yoyz";
    repo = "picoloop";
    rev = "picoloop-${finalAttrs.version}";
    sha256 = "0i8j8rgyha3ara6d4iis3wcimszf2csxdwrm5yq0wyhg74g7cvjd";
  };

  buildInputs = [
    libpulseaudio
    SDL2
    (lib.getDev SDL2)
    SDL2_image
    SDL2_ttf
    alsa-lib
    libjack2
  ];

  makeFlags = [ "-f Makefile.PatternPlayer_debian_RtAudio_sdl20" ];
  env.NIX_CFLAGS_COMPILE = toString [ "-I${lib.getInclude SDL2}/include/SDL2" ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp PatternPlayer_debian_RtAudio_sdl20 $out/bin/picoloop
    cp {font.*,LICENSE} $out/share
  '';

  hardeningDisable = [ "format" ];

  patchPhase = ''
    substituteInPlace SDL_GUI.cpp \
    --replace "\"font.ttf\"" "\"$out/share/font.ttf\"" \
    --replace "\"font.bmp\"" "\"$out/share/font.bmp\""
  '';

  sourceRoot = "${finalAttrs.src.name}/picoloop";

  meta = {
    description = "Synth and a stepsequencer (a clone of the famous nanoloop)";
    homepage = "https://github.com/yoyz/picoloop";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "picoloop";
  };
})

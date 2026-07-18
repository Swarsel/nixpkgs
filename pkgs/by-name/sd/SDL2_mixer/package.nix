{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  flac,
  fluidsynth,
  game-music-emu,
  libogg,
  libvorbis,
  libxmp,
  mpg123,
  opusfile,
  pkg-config,
  smpeg2,
  timidity,
  wavpack,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL2_mixer";
  version = "2.8.2";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_mixer";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-ln2RncnKbHIqvFia/ZlnbOGoVDJV8gF3538Wft3/wrw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    SDL2
    pkg-config
  ];

  propagatedBuildInputs = [
    SDL2
    flac
    fluidsynth
    libogg
    libvorbis
    mpg123
    opusfile
    smpeg2
    wavpack
    libxmp
    game-music-emu
    # MIDI patterns
    timidity
  ];

  configureFlags = [
    (lib.enableFeature false "music-mod-modplug-shared")
    (lib.enableFeature false "music-mp3-mpg123-shared")
    (lib.enableFeature false "music-opus-shared")
    (lib.enableFeature false "music-midi-fluidsynth-shared")
    (lib.enableFeature enableSdltest "sdltest")
    # override default path to allow MIDI files to be played
    (lib.withFeatureAs true "timidity-cfg" "${timidity}/share/timidity/timidity.cfg")
  ];

  meta = {
    description = "SDL multi-channel audio mixer library";
    homepage = "https://github.com/libsdl-org/SDL_mixer";
    license = lib.licenses.zlib;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.sdl ];
  };
})

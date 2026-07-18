{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_gfx,
  SDL2_image,
  SDL2_mixer,
  SDL2_net,
  SDL2_ttf,
  autoreconfHook,
  ffmpeg,
  fpc,
  freetype,
  libGL,
  libGLU,
  libpng,
  libx11,
  lua,
  pkg-config,
  portaudio,
  sqlite,
  zlib,
}:

let
  sharedLibs = [
    portaudio
    freetype
    SDL2
    SDL2_image
    SDL2_gfx
    SDL2_mixer
    SDL2_net
    SDL2_ttf
    sqlite
    lua
    zlib
    libx11
    libGLU
    libGL
    ffmpeg
  ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "ultrastardx";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "UltraStar-Deluxe";
    repo = "USDX";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xqP50OFUT+wreG/EZhmh5zPOwpNvG1TQkLzovgVDquI=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    fpc
    libpng
  ]
  ++ sharedLibs;

  preBuild =
    let
      items = lib.concatMapStringsSep " " (x: "-rpath ${lib.getLib x}/lib") sharedLibs;
    in
    ''
      export NIX_LDFLAGS="$NIX_LDFLAGS ${items}"
    '';

  # dlopened libgcc requires the rpath not to be shrinked
  dontPatchELF = true;

  meta = {
    description = "Free and open source karaoke game";
    homepage = "https://usdx.eu/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      diogotcorreia
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ultrastardx";
  };
})

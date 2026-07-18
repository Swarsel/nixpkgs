{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  cmake,
  copyDesktopItems,
  curl,
  libGL,
  libGLU,
  libx11,
  libxcursor,
  libxi,
  lua,
  makeDesktopItem,
  ninja,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "skyemu";
  version = "4";

  src = fetchFromGitHub {
    owner = "skylersaleh";
    repo = "SkyEmu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rfXHOff+PG5iA19iwEij4c5aFD9XrSF1GQhIBhWzKgg=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(CMAKE_OSX_ARCHITECTURES' '#set(CMAKE_OSX_ARCHITECTURES'
  '';

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    ninja
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    curl
    libGL
    libGLU
    openssl
    SDL2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
    libxi
    libxcursor
    lua
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_CURL" true)
    (lib.cmakeBool "USE_SYSTEM_OPENSSL" true)
    (lib.cmakeBool "USE_SYSTEM_SDL2" true)
    (lib.cmakeBool "ENABLE_RETRO_ACHIEVEMENTS" true)
  ];

  postInstall = ''
    install -Dm644 $src/src/resources/icons/icon.png $out/share/pixmaps/skyemu.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Emulator"
      ];

      comment = "GameBoy, GameBoy Color, GameBoy Advance, and DS emulator";
      desktopName = "SkyEmu";
      exec = "SkyEmu";
      icon = "skyemu";
      name = "skyemu";
    })
  ];

  meta = {
    description = "Low level GameBoy, GameBoy Color, Game Boy Advance, and DS emulator";
    homepage = "https://github.com/skylersaleh/SkyEmu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ liberodark ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "SkyEmu";
  };
})

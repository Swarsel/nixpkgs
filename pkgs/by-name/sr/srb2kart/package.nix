{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  cmake,
  copyDesktopItems,
  curl,
  fetchzip,
  game-music-emu,
  libpng,
  makeDesktopItem,
  makeWrapper,
  nasm,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srb2kart";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "STJr";
    repo = "Kart-Public";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5sIHdeenWZjczyYM2q+F8Y1SyLqL+y77yxYDUM3dVA0=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    nasm
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    curl
    game-music-emu
    libpng
    SDL2
    SDL2_mixer
    zlib
  ];

  cmakeFlags = [
    "-DSRB2_ASSET_DIRECTORY=${finalAttrs.assets}"
    "-DGME_INCLUDE_DIR=${game-music-emu}/include"
    "-DSDL2_MIXER_INCLUDE_DIR=${lib.getDev SDL2_mixer}/include/SDL2"
    "-DSDL2_INCLUDE_DIR=${lib.getDev SDL2}/include/SDL2"
  ];

  # Fix build with gcc15 (-std=gnu23)
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  installPhase = ''
    runHook preInstall

    install -Dm644 ../srb2.png $out/share/icons/hicolor/256x256/apps/srb2kart.png
    install -Dm755 bin/srb2kart $out/bin/srb2kart

    wrapProgram $out/bin/srb2kart \
      --set-default SRB2WADDIR ${finalAttrs.assets}

    runHook postInstall
  '';

  assets = fetchzip {
    hash = "sha256-yaVdsQUnyobjSbmemeBEyu35GeZCX1ylTRcjcbDuIu4=";
    name = "srb2kart-data";
    stripRoot = false;
    url = "https://github.com/STJr/Kart-Public/releases/download/v${finalAttrs.version}/AssetsLinuxOnly.zip";
  };

  desktopItems = [
    (makeDesktopItem rec {
      categories = [ "Game" ];
      comment = "Kart racing mod based on SRB2";
      desktopName = name;
      exec = "srb2kart";
      genericName = name;
      icon = "srb2kart";
      name = "Sonic Robo Blast 2 Kart";
      startupWMClass = ".srb2kart-wrapped";
    })
  ];

  meta = {
    description = "Classic styled kart racer";
    homepage = "https://mb.srb2.org/threads/srb2kart.25868/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ donovanglover ];
    platforms = lib.platforms.linux;
    mainProgram = "srb2kart";
  };
})

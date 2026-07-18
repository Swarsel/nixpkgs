{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  cmake,
  copyDesktopItems,
  curl,
  fetchgit,
  game-music-emu,
  libopenmpt,
  libpng,
  makeDesktopItem,
  makeWrapper,
  miniupnpc,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srb2";
  version = "2.2.15";

  src = fetchFromGitHub {
    owner = "STJr";
    repo = "SRB2";
    rev = "SRB2_release_${finalAttrs.version}";
    hash = "sha256-eJ0GYe3Rw6qQXj+jtyt8MkP87DaCiO9ffChg+SpQqaI=";
  };

  patches = [
    ./cmake.patch
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    curl
    game-music-emu
    libpng
    libopenmpt
    miniupnpc
    SDL2
    SDL2_mixer
    zlib
  ];

  cmakeFlags = [
    "-DSRB2_ASSET_DIRECTORY=${finalAttrs.assets}/share/srb2"
    "-DGME_INCLUDE_DIR=${game-music-emu}/include"
    "-DOPENMPT_INCLUDE_DIR=${libopenmpt.dev}/include"
    "-DSDL2_MIXER_INCLUDE_DIR=${lib.getDev SDL2_mixer}/include/SDL2"
    "-DSDL2_INCLUDE_DIR=${lib.getInclude SDL2}/include/SDL2"
  ];

  # Fix build with gcc15 (-std=gnu23)
  # Note that upstream fixed compatibility with C23 as of commit 639b58c6d718452ef343a0bc927d043bed9e40d6,
  # so it's likely this can be removed on the next version after 2.2.15.
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications
    copyDesktopItems

    install -D ../srb2.png -t $out/share/icons/hicolor/256x256/apps

    cp bin/lsdlsrb2 $out/bin/srb2
    wrapProgram $out/bin/srb2 --set SRB2WADDIR "${finalAttrs.assets}/share/srb2"

    runHook postInstall
  '';

  assets = stdenv.mkDerivation {
    pname = "srb2-data";
    version = finalAttrs.version;

    src = fetchgit {
      url = "https://git.do.srb2.org/STJr/srb2assets-public";
      rev = "SRB2_release_${finalAttrs.version}";
      hash = "sha256-1kwhWHzL2TbSx1rhFExbMhXqn0HMBRhR6LZiuoRx+iI=";
      fetchLFS = true;
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/srb2
      cp -r * $out/share/srb2

      runHook postInstall
    '';
  };

  desktopItems = [
    (makeDesktopItem rec {
      categories = [ "Game" ];
      comment = finalAttrs.meta.description;
      desktopName = name;
      exec = "srb2";
      genericName = name;
      icon = "srb2";
      name = "Sonic Robo Blast 2";
      startupWMClass = ".srb2-wrapped";
    })
  ];

  meta = {
    description = "Sonic Robo Blast 2 is a 3D Sonic the Hedgehog fangame based on a modified version of Doom Legacy";
    homepage = "https://www.srb2.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      zeratax
      donovanglover
    ];

    platforms = lib.platforms.linux;
    mainProgram = "srb2";
  };
})

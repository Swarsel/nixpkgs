{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  copyDesktopItems,
  file,
  libGL,
  libogg,
  libvorbis,
  libx11,
  makeDesktopItem,
  makeWrapper,
  openal,
  pkg-config,
  zlib,
  client ? true,
  server ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "assaultcube";
  version = "1.3.0.2";

  src = fetchFromGitHub {
    owner = "assaultcube";
    repo = "AC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6UfOKgI+6rMGNHlRQnVCm/zD3wCKwbeOD7jgxH8aY2M=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    file
    zlib
  ]
  ++ lib.optionals client [
    openal
    SDL2
    SDL2_image
    libGL
    libx11
    libogg
    libvorbis
  ];

  makeFlags = [
    "-C source/src"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ]
  ++ lib.optionals server [ "server" ]
  ++ lib.optionals client [ "client" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/games/assaultcube

    cp -r config packages $out/share/games/assaultcube

    if (test -e source/src/ac_client) then
      cp source/src/ac_client $out/bin
      mkdir -p $out/share/applications
      install -Dpm644 packages/misc/icon.png $out/share/icons/hicolor/32x32/apps/assaultcube.png

      makeWrapper $out/bin/ac_client $out/bin/assaultcube \
        --chdir "$out/share/games/assaultcube" --add-flags "--home=\$HOME/.assaultcube/v1.2next --init"
    fi

    if (test -e source/src/ac_server) then
      cp source/src/ac_server $out/bin
      makeWrapper $out/bin/ac_server $out/bin/assaultcube-server \
        --chdir "$out/share/games/assaultcube" --add-flags "-Cconfig/servercmdline.txt"
    fi

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ActionGame"
        "Shooter"
      ];

      comment = "A multiplayer, first-person shooter game, based on the CUBE engine. Fast, arcade gameplay.";
      desktopName = "AssaultCube";
      exec = "assaultcube";
      genericName = "First-person shooter";
      icon = "assaultcube";
      name = "assaultcube";
    })
  ];

  meta = {
    description = "Fast and fun first-person-shooter based on the Cube fps";
    homepage = "https://assault.cubers.net";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ darkonion0 ];
    platforms = lib.platforms.linux; # should work on darwin with a little effort.
  };
})

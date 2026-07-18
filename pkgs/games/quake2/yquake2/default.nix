{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  buildEnv,
  copyDesktopItems,
  curl,
  libGL,
  makeDesktopItem,
  makeWrapper,
  openal,
  openalSupport ? true,
}:

let
  games = import ./games.nix { inherit stdenv lib fetchFromGitHub; };

  wrapper = import ./wrapper.nix {
    inherit
      stdenv
      lib
      buildEnv
      makeWrapper
      yquake2
      copyDesktopItems
      makeDesktopItem
      ;
  };

  yquake2 = stdenv.mkDerivation rec {
    pname = "yquake2";
    version = "8.60";

    src = fetchFromGitHub {
      owner = "yquake2";
      repo = "yquake2";
      rev = "QUAKE2_${builtins.replaceStrings [ "." ] [ "_" ] version}";
      sha256 = "sha256-XD0Fnx3TZwZUvjLOpzM5oWoIQFykDuBOddQXudkiyB0=";
    };

    postPatch = ''
      substituteInPlace src/client/curl/qcurl.c \
        --replace "\"libcurl.so.3\", \"libcurl.so.4\"" "\"${curl.out}/lib/libcurl.so\", \"libcurl.so.3\", \"libcurl.so.4\""
    ''
    + lib.optionalString (openalSupport && !stdenv.hostPlatform.isDarwin) ''
      substituteInPlace Makefile \
        --replace "\"libopenal.so.1\"" "\"${openal}/lib/libopenal.so.1\""
    '';

    nativeBuildInputs = [ copyDesktopItems ];

    buildInputs = [
      SDL2
      libGL
      curl
    ]
    ++ lib.optional openalSupport openal;

    makeFlags = [
      "WITH_OPENAL=${lib.boolToYesNo openalSupport}"
      "WITH_SYSTEMWIDE=yes"
      "WITH_SYSTEMDIR=\${out}/share/games/quake2"
    ];

    installPhase = ''
      runHook preInstall
      # Yamagi Quake II expects all binaries (executables and libs) to be in the
      # same directory.
      mkdir -p $out/bin $out/lib/yquake2 $out/share/games/quake2/baseq2
      cp -r release/* $out/lib/yquake2
      ln -s $out/lib/yquake2/quake2 $out/bin/yquake2
      ln -s $out/lib/yquake2/q2ded $out/bin/yq2ded
      cp $src/stuff/yq2.cfg $out/share/games/quake2/baseq2
      install -Dm644 stuff/icon/Quake2.png $out/share/icons/hicolor/512x512/apps/yamagi-quake2.png;
      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [
          "Game"
          "Shooter"
        ];

        comment = "Yamagi Quake II client";
        desktopName = "yquake2";
        exec = "yquake2";
        icon = "yamagi-quake2";
        name = "yquake2";
      })
    ];

    enableParallelBuilding = true;

    meta = {
      description = "Yamagi Quake II client";
      homepage = "https://www.yamagi.org/quake2/";
      license = lib.licenses.gpl2Plus;
      maintainers = with lib.maintainers; [ tadfisher ];
      platforms = lib.platforms.unix;
    };
  };

in
{
  inherit yquake2;

  yquake2-all-games = wrapper {
    description = "Yamagi Quake II with all add-on games";
    games = lib.attrValues games;
    name = "yquake2-all-games";
  };

  yquake2-ctf = wrapper {
    inherit (games.ctf) description;
    games = [ games.ctf ];
    name = "yquake2-ctf";
  };

  yquake2-ground-zero = wrapper {
    inherit (games.ground-zero) description;
    games = [ games.ground-zero ];
    name = "yquake2-ground-zero";
  };

  yquake2-the-reckoning = wrapper {
    inherit (games.the-reckoning) description;
    games = [ games.the-reckoning ];
    name = "yquake2-the-reckoning";
  };
}

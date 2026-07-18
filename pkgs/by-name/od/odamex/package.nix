{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  SDL2_net,
  alsa-lib,
  cmake,
  copyDesktopItems,
  cpptrace,
  curl,
  expat,
  fltk_1_4,
  libdwarf,
  libselinux,
  libsepol,
  libsysprof-capture,
  libuuid,
  libx11,
  libxdmcp,
  libxkbcommon,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  pcre2,
  pkg-config,
  portmidi,
  python3,
  wayland-scanner,
  waylandpp,
  wrapGAppsHook3,
  wxwidgets_3_2,
  xorgproto,
  zstd,
  withWayland ? stdenv.hostPlatform.isLinux,
  withX11 ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "odamex";
  version = "12.2.0";

  src = fetchFromGitHub {
    owner = "odamex";
    repo = "odamex";
    tag = finalAttrs.version;
    hash = "sha256-cRQtY4C0gjzheE4cG8aPjzAoPf/Hm05a6tidsbce7uM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    python3
    makeWrapper
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    SDL2_net
    cpptrace
    curl
    expat
    fltk_1_4
    libdwarf
    libsysprof-capture
    pcre2
    portmidi
    wxwidgets_3_2
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libselinux
    libuuid
    libxdmcp
    libsepol
  ]
  ++ lib.optionals withX11 [
    libx11
    xorgproto
  ]
  ++ lib.optionals withWayland [
    libxkbcommon
    wayland-scanner
    waylandpp
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_INTERNAL_CPPTRACE" false)
    (lib.cmakeFeature "ODAMEX_INSTALL_BINDIR" "$ODAMEX_BINDIR") # set by wrapper
  ];

  installPhase = ''
    runHook preInstall

    ${
      if stdenv.hostPlatform.isDarwin then
        # bash
        ''
          mkdir -p $out/{Applications,bin}

          mv client odamex
          for name in odamex odalaunch; do
            contents="Applications/$name.app/Contents/MacOS"
            mv $name/*.app $out/Applications
            makeWrapper $out/{"$contents",bin}/"$name" \
              --set ODAMEX_BINDIR "${placeholder "out"}/Applications"
          done

          cp server/odasrv $out/Applications
          ln -s $out/Applications/odamex.app/Contents/MacOS/odamex.wad $out/Applications
          makeWrapper $out/{Applications,bin}/odasrv
        ''
      else
        # bash
        ''
          make install

          # copy desktop file icons
          for name in odamex odalaunch odasrv; do
            for size in 96 128 256 512; do
              install -Dm644 ../media/icon_"$name"_"$size".png \
                $out/share/icons/hicolor/"$size"x"$size"/apps/"$name".png
            done
          done
        ''
    }

    runHook postInstall
  '';

  preFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    gappsWrapperArgs+=(
      --set ODAMEX_BINDIR "${placeholder "out"}/bin"
    )
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "ActionGame"
        "Game"
        "Shooter"
      ];

      comment = "A Doom multiplayer game engine";
      desktopName = "Odamex Client";
      exec = "odamex";
      icon = "odamex";
      name = "odamex";
    })
    (makeDesktopItem {
      categories = [
        "ActionGame"
        "Game"
        "Shooter"
      ];

      comment = "Server Browser for Odamex";
      desktopName = "Odamex Launcher";
      exec = "odalaunch";
      icon = "odalaunch";
      name = "odalaunch";
    })
    (makeDesktopItem {
      categories = [
        "Network"
      ];

      comment = "Run an Odamex game server";
      desktopName = "Odamex Server";
      exec = "odasrv";
      icon = "odasrv";
      name = "odasrv";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Client/server port for playing old-school Doom online";
    homepage = "https://odamex.net";
    changelog = "https://github.com/odamex/odamex/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ eljamm ];
    platforms = lib.platforms.unix;
    mainProgram = "odalaunch";
  };
})

{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
  pkg-config,
  wrapGAppsHook3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plus42";
  version = "1.3.15";

  src = fetchurl {
    url = "https://thomasokken.com/plus42/upstream/plus42-upstream-${finalAttrs.version}.tgz";
    hash = "sha256-qJteqxEDVdqgPdIQCOsNvdPS7S7pq/nVfavfXdOrnAQ=";
  };

  postPatch = ''
    substituteInPlace gtk/Makefile \
      --replace-fail /bin/ls ls
  '';

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [ alsa-lib ];

  buildPhase = ''
    runHook preBuild

    make -C gtk cleaner
    make --jobs=$NIX_BUILD_CORES -C gtk AUDIO_ALSA=1
    make -C gtk clean
    make --jobs=$NIX_BUILD_CORES -C gtk AUDIO_ALSA=1 BCD_MATH=1

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install --directory $out/bin \
                        $out/share/doc/plus42 \
                        $out/share/plus42/skins \
                        $out/share/icons/hicolor/48x48/apps \
                        $out/share/icons/hicolor/128x128/apps

    install -m755 gtk/plus42dec gtk/plus42bin $out/bin
    install -m644 README $out/share/doc/plus42/README

    install -m644 gtk/icon-48x48.png $out/share/icons/hicolor/48x48/apps/plus42.png
    install -m644 gtk/icon-128x128.png $out/share/icons/hicolor/128x128/apps/plus42.png
    install -m644 skins/* $out/share/plus42/skins

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/plus42dec \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ alsa-lib ]} \
      "''${gappsWrapperArgs[@]}"

    wrapProgram $out/bin/plus42bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ alsa-lib ]} \
      "''${gappsWrapperArgs[@]}"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Calculator"
      ];

      comment = "Software clone of the HP-42S calculator (enhanced version)";
      desktopName = "Plus42Bin";
      exec = "plus42bin";
      genericName = "Calculator";
      icon = "plus42";
      name = "plus42bin";
      type = "Application";
    })
    (makeDesktopItem {
      categories = [
        "Utility"
        "Calculator"
      ];

      comment = "Software clone of the HP-42S calculator (enhanced version)";
      desktopName = "Plus42Dec";
      exec = "plus42dec";
      genericName = "Calculator";
      icon = "plus42";
      name = "plus42dec";
      type = "Application";
    })
  ];

  dontConfigure = true;
  dontWrapGApps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--url=https://codeberg.org/thomasokken/plus42desktop" ];
  };

  meta = {
    description = "Software clone of the HP-42S calculator (enhanced version)";
    homepage = "https://thomasokken.com/plus42/";
    changelog = "https://thomasokken.com/plus42/history.html";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ elfenermarcell ];
    platforms = with lib.platforms; unix;
    mainProgram = "plus42dec";
  };
})

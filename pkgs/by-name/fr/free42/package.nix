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
  pname = "free42";
  version = "3.3.12";

  src = fetchurl {
    url = "https://thomasokken.com/free42/upstream/free42-nologo-${finalAttrs.version}.tgz";
    hash = "sha256-Ybr5IwqYBIXGWcLBM2drKuN2NDBta299X/3hvzvGPeU=";
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
                        $out/share/doc/free42 \
                        $out/share/free42/skins \
                        $out/share/icons/hicolor/48x48/apps \
                        $out/share/icons/hicolor/128x128/apps

    install -m755 gtk/free42dec gtk/free42bin $out/bin
    install -m644 README $out/share/doc/free42/README

    install -m644 gtk/icon-48x48.png $out/share/icons/hicolor/48x48/apps/free42.png
    install -m644 gtk/icon-128x128.png $out/share/icons/hicolor/128x128/apps/free42.png
    install -m644 skins/* $out/share/free42/skins

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/free42dec \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ alsa-lib ]} \
      "''${gappsWrapperArgs[@]}"

    wrapProgram $out/bin/free42bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ alsa-lib ]} \
      "''${gappsWrapperArgs[@]}"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Calculator"
      ];

      comment = "Software clone of the HP-42S calculator";
      desktopName = "Free42Bin";
      exec = "free42bin";
      genericName = "Calculator";
      icon = "free42";
      name = "free42bin";
      type = "Application";
    })
    (makeDesktopItem {
      categories = [
        "Utility"
        "Calculator"
      ];

      comment = "Software clone of the HP-42S calculator";
      desktopName = "Free42Dec";
      exec = "free42dec";
      genericName = "Calculator";
      icon = "free42";
      name = "free42dec";
      type = "Application";
    })
  ];

  dontConfigure = true;
  dontWrapGApps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--url=https://codeberg.org/thomasokken/free42" ];
  };

  meta = {
    description = "Software clone of the HP-42S calculator";
    homepage = "https://thomasokken.com/free42/";
    changelog = "https://thomasokken.com/free42/history.html";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ elfenermarcell ];
    platforms = with lib.platforms; unix;
    mainProgram = "free42dec";
  };
})

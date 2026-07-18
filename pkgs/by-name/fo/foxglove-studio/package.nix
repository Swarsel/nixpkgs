{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-core,
  autoPatchelfHook,
  copyDesktopItems,
  dpkg,
  gtk3,
  libGL,
  libappindicator,
  libdrm,
  libgbm,
  libnotify,
  libxcb,
  makeDesktopItem,
  makeWrapper,
  nss,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "foxglove-studio";
  version = "2.49.0";

  src = fetchurl {
    url = "https://get.foxglove.dev/desktop/v${finalAttrs.version}/foxglove-studio-${finalAttrs.version}-linux-amd64.deb";
    hash = "sha256-y6EowFo1XjC8A+kj3xc1YtcNqE6UPpwb21q28Qe/AmM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    gtk3
    libGL
    libappindicator
    libdrm
    libgbm
    libnotify
    libxcb
    nss
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,opt,share}

    cp -r opt/Foxglove $out/opt/
    cp -r usr/share/icons $out/share/
    cp -r usr/share/mime $out/share/

    ln -s "$out/opt/Foxglove/foxglove-studio" $out/bin/foxglove-studio

    runHook postInstall
  '';

  preFixup = "patchelf --add-needed libGL.so.1 --add-needed libEGL.so.1 $out/opt/Foxglove/foxglove-studio";

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      comment = "Integrated robotics visualization and debugging";
      desktopName = "Foxglove Studio";
      exec = "foxglove-studio %U";
      icon = "foxglove-studio";

      mimeTypes = [
        "application/octet-stream"
        "application/zip"
        "x-scheme-handler/foxglove"
      ];

      name = "foxglove-studio";
    })
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Visualization and observability platform for robotics";
    homepage = "https://foxglove.dev/";
    changelog = "https://docs.foxglove.dev/changelog/foxglove/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ sascha8a ];
    platforms = [ "x86_64-linux" ];
    downloadPage = "https://foxglove.dev/download";
    hydraPlatforms = [ ];
  };
})

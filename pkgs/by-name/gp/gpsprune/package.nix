{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  jre,
  makeDesktopItem,
  makeWrapper,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpsprune";
  version = "25";

  src = fetchurl {
    url = "https://activityworkshop.net/software/gpsprune/gpsprune_${finalAttrs.version}.jar";
    hash = "sha256-8FGOigjHIvj+CZwq0Lht7UZjtmrE5l2Aqx92gZjau44=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [ jre ];

  installPhase = ''
    runHook preInstall

    install -Dm644 ${finalAttrs.src} $out/share/java/gpsprune.jar
    makeWrapper ${jre}/bin/java $out/bin/gpsprune \
      --add-flags "-jar $out/share/java/gpsprune.jar"
    mkdir -p $out/share/icons/hicolor/64x64/apps
    ${unzip}/bin/unzip -p $src tim/prune/gui/images/window_icon_64.png > $out/share/icons/hicolor/64x64/apps/gpsprune.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Education"
        "Geoscience"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "GpsPrune";
      exec = "gpsprune %F";
      genericName = "GPS Data Editor";
      icon = "gpsprune";

      mimeTypes = [
        "application/gpx+xml"
        "application/vnd.google-earth.kml+xml"
        "application/vnd.google-earth.kmz"
      ];

      name = "gpsprune";
    })
  ];

  dontUnpack = true;

  meta = {
    description = "Application for viewing, editing and converting GPS coordinate data";
    homepage = "https://activityworkshop.net/software/gpsprune/";
    changelog = "https://activityworkshop.net/software/gpsprune/whats_new.html";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ rycee ];
    platforms = lib.platforms.all;
    mainProgram = "gpsprune";
  };
})

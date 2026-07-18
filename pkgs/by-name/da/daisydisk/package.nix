{
  lib,
  cacert,
  common-updater-scripts,
  curl,
  fetchzip,
  stdenvNoCC,
  writeShellApplication,
  xmlstarlet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "daisydisk";
  version = "4.34.2";

  src = fetchzip {
    url = "https://daisydiskapp.com/download/DaisyDisk.zip";
    hash = "sha256-lSV367twsKDp0e5TsVYfjYO5GPcjtteBCxmUIOrz+0E=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv DaisyDisk.app $out/Applications

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontPatch = true;

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "daisydisk-update-script";

    runtimeInputs = [
      curl
      cacert
      xmlstarlet
      common-updater-scripts
    ];

    text = ''
      url="https://daisydiskapp.com/downloads/appcastFeed.php"
      version=$(curl -s "$url" |  xmlstarlet sel -t -v 'rss/channel/item[1]/enclosure/@sparkle:version' -n)
      update-source-version daisydisk "$version"
    '';
  });

  meta = {
    description = "Find out what’s taking up your disk space and recover it in the most efficient and easy way";
    homepage = "https://daisydiskapp.com/";
    changelog = "https://daisydiskapp.com/releases";
    license = [ lib.licenses.unfree ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ DimitarNestorov ];
    platforms = lib.platforms.darwin;
  };
})

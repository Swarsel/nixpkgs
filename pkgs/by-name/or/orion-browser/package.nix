{
  lib,
  fetchurl,
  makeWrapper,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "orion-browser";
  version = "149";

  src = fetchurl {
    url = "https://cdn.kagi.com/updates/26_0/${finalAttrs.version}.zip";
    hash = "sha256-C0mtGNE9Or0alFe2Gu4LkRcHMvk1RLXZ/mUo/XtWB2g=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R Orion.app "$out/Applications"
    makeWrapper "$out/Applications/Orion.app/Contents/MacOS/Orion" "$out/bin/orion"

    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";
  unpackCmd = "unzip -q $curSrc -x '__MACOSX/*'";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "WebKit-based web browser by Kagi";
    homepage = "https://orionbrowser.com/";
    changelog = "https://orionbrowser.com/updates/orion-release-notes";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ pradyuman ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "orion";
  };
})

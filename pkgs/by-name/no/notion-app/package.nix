{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:
let
  info = lib.importJSON ./source.json;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "notion-app";
  version = info.version;
  src = fetchurl { inherit (info) url hash; };
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Notion.app $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = ./update/update.mjs;

  meta = {
    description = "App to write, plan, collaborate, and get organised";
    homepage = "https://www.notion.so/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      xiaoxiangmoe
      pradyuman
    ];

    platforms = [
      "aarch64-darwin"
    ];
  };
})

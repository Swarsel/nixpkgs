{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nxengine-assets";
  version = "2.6.5-1";

  src = fetchzip {
    url = "https://github.com/nxengine/nxengine-evo/releases/download/v${finalAttrs.version}/NXEngine-Evo-v${finalAttrs.version}-Win64.zip";
    hash = "sha256-+PjjhJYL1yk67QJ7ixfpCRg1coQnSPpXDUIwsqp9aIM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nxengine/
    cp -r data/ $out/share/nxengine/data

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Assets for nxengine-evo";
    homepage = "https://github.com/nxengine/nxengine-evo";

    license = with lib.licenses; [
      unfreeRedistributable
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})

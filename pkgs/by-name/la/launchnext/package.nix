{
  lib,
  fetchzip,
  nix-update-script,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "launchnext";
  version = "2.4.0";

  src = fetchzip {
    url = "https://github.com/RoversX/LaunchNext/releases/download/${finalAttrs.version}/LaunchNext${finalAttrs.version}.zip";
    hash = "sha256-o52vYFr2j3AtFOpTyZ4jBnPhpfRGjyBXp5ZM4hlXqvU=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R LaunchNext.app $out/Applications/

    runHook postInstall
  '';

  doInstallCheck = true;
  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bring Launchpad back in MacOS26+, highly customizable, powerful, free";
    homepage = "https://closex.org/launchnext/";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      Renna42
    ];

    platforms = lib.platforms.darwin;
  };
})

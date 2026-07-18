{
  lib,
  fetchzip,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "whisky";
  version = "2.3.5";

  src = fetchzip {
    url = "https://github.com/IsaacMarovitz/Whisky/releases/download/v${finalAttrs.version}/Whisky.zip";
    hash = "sha256-tETDj83dCZJdJCGpXyK6pdhwr70sYWCknBHybMAWHzU=";
    extension = "zip";
    name = "Whisky.app";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -r *.app "$out/Applications"

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wine wrapper built with SwiftUI";
    homepage = "https://getwhisky.app/";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ iivusly ];
    platforms = lib.platforms.darwin;
  };
})

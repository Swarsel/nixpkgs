{
  lib,
  fetchzip,
  makeWrapper,
  stdenvNoCC,
}:
let
  build = "536";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "swiftbar";
  version = "2.0.1";

  src = fetchzip {
    url = "https://github.com/swiftbar/SwiftBar/releases/download/v${finalAttrs.version}/SwiftBar.v${finalAttrs.version}.b${build}.zip";
    hash = "sha256-K46XQvhLs8rnQ0psveL2dZ/+bTZnaeWVLtrUm29RQYU=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{Applications,bin}
    cp -r ./SwiftBar.app $out/Applications

    # Symlinking doesnt work; The auto-updater will fail to start which renders the app useless
    makeWrapper $out/Applications/SwiftBar.app/Contents/MacOS/SwiftBar $out/bin/SwiftBar

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Powerful macOS menu bar customization tool";
    homepage = "https://swiftbar.app";
    changelog = "https://github.com/swiftbar/SwiftBar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ matteopacini ];
    platforms = lib.platforms.darwin;
    mainProgram = "SwiftBar";
  };
})

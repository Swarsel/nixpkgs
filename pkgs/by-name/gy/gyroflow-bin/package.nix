{
  lib,
  fetchurl,
  _7zz,
  gyroflow,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gyroflow-bin";
  version = "1.6.3";

  src = fetchurl {
    url = "https://github.com/gyroflow/gyroflow/releases/download/v${finalAttrs.version}/Gyroflow-mac-universal.dmg";
    hash = "sha256-++Jnk8Y58UENiZXeutGIchWHEIy2p0Ik6Hn3nku4ocA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    _7zz
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r "Gyroflow v${finalAttrs.version}/Gyroflow.app" $out/Applications/

    makeWrapper $out/Applications/Gyroflow.app/Contents/MacOS/gyroflow $out/bin/gyroflow

    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = gyroflow.meta // {
    description = "Advanced gyro-based video stabilization tool (pre-built macOS binary)";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ Br1ght0ne ];
    platforms = lib.platforms.darwin;
    mainProgram = "gyroflow";
  };
})

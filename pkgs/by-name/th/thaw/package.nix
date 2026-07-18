{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "thaw";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/stonerl/Thaw/releases/download/${finalAttrs.version}/Thaw_${finalAttrs.version}.zip";
    hash = "sha256-1n9NMe+foFeEmphUC4EM+kLgvGYBnTYFq9CORcaaoG8=";
  };

  strictDeps = true;
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -r Thaw.app "$out/Applications"
    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Menu bar manager for macOS 26";
    homepage = "https://github.com/stonerl/Thaw";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ Br1ght0ne ];
    platforms = lib.platforms.darwin;
  };
})

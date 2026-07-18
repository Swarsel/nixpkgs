{
  lib,
  fetchurl,
  _7zz,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lunar";
  version = "6.9.7";

  src = fetchurl {
    url = "https://github.com/alin23/Lunar/releases/download/v${finalAttrs.version}/Lunar-${finalAttrs.version}.dmg";
    hash = "sha256-CqxhLUL/Vnt665xcZFaXg/MWywca6j/pr03oLoyofYQ=";
  };

  nativeBuildInputs = [ _7zz ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R ./Lunar.app $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Defacto app for controlling monitors";
    homepage = "https://lunar.fyi/";
    changelog = "https://github.com/alin23/Lunar/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      unfree
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ delafthi ];

    platforms = [
      "aarch64-darwin"
    ];
  };
})

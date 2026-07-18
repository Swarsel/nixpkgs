{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "macshot";
  version = "4.1.2";

  src = fetchurl {
    url = "https://github.com/sw33tLie/macshot/releases/download/v${finalAttrs.version}/MacShot.dmg";
    hash = "sha256-5o8l6MvGs58zSPKaR4RQZ2UgWsqcQRaRUsd8cS62VVg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    undmg
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R macshot.app "$out/Applications/"

    mkdir -p "$out/bin"
    ln -s "$out/Applications/macshot.app/Contents/MacOS/macshot" "$out/bin/macshot"

    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Feature-packed native macOS screenshot & recording tool";
    homepage = "https://github.com/sw33tLie/macshot";
    changelog = "https://github.com/sw33tLie/macshot/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.darwin;
    mainProgram = "macshot";
  };
})

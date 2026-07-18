{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deck-app";
  version = "1.4.5";

  src = fetchurl {
    url = "https://github.com/yuzeguitarist/Deck/releases/download/v${finalAttrs.version}/Deck.dmg";
    hash = "sha256-U5iMoQZGycwiiehxKUB3iohvzAh42gkC1sk3AJ62Ujs=";
  };

  strictDeps = true;
  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontFixup = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Deck is a modern, native, privacy-first clipboard manager for macOS.";
    homepage = "https://deckclip.app/";
    changelog = "https://github.com/yuzeguitarist/Deck/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ myzel394 ];
    platforms = lib.platforms.darwin;
    # Deck provides a CLI tool that can be enabled in the app settings.
    mainProgram = "deckclip";
  };
})

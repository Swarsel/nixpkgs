{
  lib,
  fetchzip,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "qlmarkdown";
  version = "1.5.2";

  src = fetchzip {
    url = "https://github.com/sbarex/QLMarkdown/releases/download/${finalAttrs.version}/QLMarkdown.zip";
    hash = "sha256-duQwlY87yWKn5RXEaPqZz8oICIsHid8m1i5V7+5bIf4=";
    stripRoot = false;
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R "QLMarkdown.app" "$out/Applications/"

    ln -s \
      "$out/Applications/QLMarkdown.app/Contents/Resources/qlmarkdown_cli" \
      "$out/bin/qlmarkdown_cli"

    runHook postInstall
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Quick Look extension for Markdown previews on macOS";
    homepage = "https://github.com/sbarex/QLMarkdown";
    changelog = "https://github.com/sbarex/QLMarkdown/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ kinnrai ];
    platforms = lib.platforms.darwin;
    mainProgram = "qlmarkdown_cli";
  };
})

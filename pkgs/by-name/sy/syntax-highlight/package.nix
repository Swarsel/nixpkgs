{
  lib,
  fetchzip,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "syntax-highlight";
  version = "2.1.30";

  src = fetchzip {
    url = "https://github.com/sbarex/SourceCodeSyntaxHighlight/releases/download/${finalAttrs.version}/Syntax.Highlight.zip";
    hash = "sha256-URjobIBo43xtc2S6Ppr88lzeTo5KdbhF2T5weUjaxsA=";
    stripRoot = false;
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R "Syntax Highlight.app" "$out/Applications/"

    ln -s \
      "$out/Applications/Syntax Highlight.app/Contents/Resources/syntax_highlight_cli" \
      "$out/bin/syntax_highlight_cli"

    runHook postInstall
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Quick Look extension for syntax-highlighted source file previews on macOS";
    homepage = "https://github.com/sbarex/SourceCodeSyntaxHighlight";
    changelog = "https://github.com/sbarex/SourceCodeSyntaxHighlight/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ kinnrai ];
    platforms = lib.platforms.darwin;
    mainProgram = "syntax_highlight_cli";
  };
})

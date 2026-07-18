{
  lib,
  fetchurl,
  makeBinaryWrapper,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kiwix-apple";
  version = "3.15.1";

  src = fetchurl {
    url = "https://download.kiwix.org/release/kiwix-macos/kiwix-macos_${finalAttrs.version}.dmg";
    hash = "sha256-3wZ7zavLmLyPYGrdFpnhd8a1paI65yHFdL6JzL1e0e0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    undmg
  ];

  postInstall = ''
    mkdir -p $out/Applications
    cp -r Kiwix.app $out/Applications
    makeWrapper $out/Applications/Kiwix.app/Contents/MacOS/Kiwix $out/bin/${finalAttrs.meta.mainProgram}
  '';

  sourceRoot = ".";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--url=https://github.com/kiwix/kiwix-apple"
      "--version-regex=(.*\\..*\\..*)" # matches arbitrary tags otherwise
    ];
  };

  meta = {
    description = "Offline reader for Web content";
    homepage = "https://get.kiwix.org/en/solutions/applications/";
    changelog = "https://github.com/kiwix/kiwix-apple/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MysteryBlokHed ];
    platforms = lib.platforms.darwin;
    mainProgram = "kiwix";
    downloadPage = "https://get.kiwix.org/en/solutions/applications/kiwix-reader/";
  };
})

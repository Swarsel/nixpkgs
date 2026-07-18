{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "instant-space-switcher";
  version = "2.0";

  src = fetchurl {
    url = "https://github.com/jurplel/InstantSpaceSwitcher/releases/download/v${finalAttrs.version}/InstantSpaceSwitcher-${finalAttrs.version}.dmg";
    hash = "sha256-48DH2Hu/XhLPr8jP2ArmLJLFbJmIupkrlqlFOsNnL7g=";
  };

  strictDeps = true;
  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R InstantSpaceSwitcher.app "$out/Applications/"
    ln -s "$out/Applications/InstantSpaceSwitcher.app/Contents/MacOS/ISSCli" "$out/bin/isscli"

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontFixup = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native instant workspace switching on macOS. No more waiting for animations";
    homepage = "https://github.com/jurplel/InstantSpaceSwitcher";
    changelog = "https://github.com/jurplel/InstantSpaceSwitcher/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ myzel394 ];
    platforms = lib.platforms.darwin;
    mainProgram = "isscli";
  };
})

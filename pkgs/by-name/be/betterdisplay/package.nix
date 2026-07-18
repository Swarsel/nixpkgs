{
  lib,
  fetchurl,
  nix-update-script,
  re-plistbuddy,
  stdenvNoCC,
  undmg,
  versionCheckHook,
  writeShellScript,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "betterdisplay";
  version = "4.3.4";

  src = fetchurl {
    url = "https://github.com/waydabber/BetterDisplay/releases/download/v${finalAttrs.version}/BetterDisplay-v${finalAttrs.version}.dmg";
    hash = "sha256-I0Ei9+TsbmsA6iFD1CwScgrU7OO9mL3fl3/uvCYS4JI=";
  };

  buildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv BetterDisplay.app $out/Applications

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontPatch = true;
  sourceRoot = ".";

  versionCheckProgram = writeShellScript "version-check" ''
    ${lib.getExe' re-plistbuddy "PlistBuddy"} -c "Print :CFBundleShortVersionString" "$1"
  '';

  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/BetterDisplay.app/Contents/Info.plist"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unlock your displays on your Mac! Flexible HiDPI scaling, XDR/HDR extra brightness, virtual screens, DDC control, extra dimming, PIP/streaming, EDID override and lots more";
    homepage = "https://betterdisplay.pro/";
    changelog = "https://github.com/waydabber/BetterDisplay/releases/tag/v${finalAttrs.version}";
    license = [ lib.licenses.unfree ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ DimitarNestorov ];
    platforms = lib.platforms.darwin;
  };
})

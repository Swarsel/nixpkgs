{
  lib,
  fetchurl,
  _7zz,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yubiswitch";
  version = "0.18";

  src = fetchurl {
    url = "https://github.com/pallotron/yubiswitch/releases/download/v${finalAttrs.version}/yubiswitch_${finalAttrs.version}.dmg";
    hash = "sha256-ee7l8jj1pJdj+SjMNWcLfHV//G0FG9bdBkNcxUh8Zuk=";
  };

  nativeBuildInputs = [ _7zz ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R yubiswitch.app "$out/Applications"

    runHook postInstall
  '';

  sourceRoot = ".";

  meta = {
    description = "The macOS status bar application to enable/disable Yubikeys.";
    homepage = "https://github.com/pallotron/yubiswitch";
    changelog = "https://github.com/pallotron/yubiswitch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ sheeeng ];
    platforms = lib.platforms.darwin;
  };
})

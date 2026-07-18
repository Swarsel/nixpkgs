{
  lib,
  fetchurl,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rectangle-pro";
  version = "3.75";

  src = fetchurl {
    url = "https://rectangleapp.com/pro/downloads/Rectangle%20Pro%20${finalAttrs.version}.dmg";
    hash = "sha256-1NIR3iql9+e2nX/mzThkJ2LnLi0onrgF8gLwFBf2iKc=";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -r *.app "$out/Applications"

    runHook postInstall
  '';

  sourceRoot = ".";

  meta = {
    description = "Move and resize windows in macOS using keyboard shortcuts or snap areas";
    homepage = "https://rectangleapp.com/pro";
    changelog = "https://rectangleapp.com/pro/versions";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = lib.platforms.darwin;
  };
})

{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "reflex-app";
  version = "2.0";

  src = fetchurl {
    url = "https://stuntsoftware.com/download/reflex_${finalAttrs.version}.zip";
    hash = "sha256-2CfNMs9zDFyFgrIAuh37bB3wPjDDrGsyyFY65n0CtIk=";
  };

  strictDeps = true;
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R Reflex.app "$out/Applications"

    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";

  meta = {
    description = "Media key forwarder for Music and Spotify";
    homepage = "https://stuntsoftware.com/reflex/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ wini ];
    platforms = lib.platforms.darwin;
  };
})

{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ice-bar";
  version = "0.11.12";

  src = fetchurl {
    url = "https://github.com/jordanbaird/Ice/releases/download/${finalAttrs.version}/Ice.zip";
    hash = "sha256-13DoFZdWbdLSNj/rNQ+AjHqS42PflcUeSBQOsw5FLMk=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -r *.app "$out/Applications"

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Powerful menu bar manager for macOS";
    homepage = "https://icemenubar.app/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ _4evy ];
    platforms = lib.platforms.darwin;
  };
})

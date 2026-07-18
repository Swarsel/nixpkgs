{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "swift-quit";
  version = "1.5";

  src = fetchurl {
    url = "https://github.com/onebadidea/swiftquit/releases/download/v${finalAttrs.version}/Swift.Quit.zip";
    sha256 = "sha256-pORnyxOhTc/zykBHF5ujsWEZ9FjNauJGeBDz9bnHTvs=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    unzip -d $out/Applications $src

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Automatic quitting of macOS apps when closing their windows";
    homepage = "https://swiftquit.com/";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ Enzime ];
    platforms = lib.platforms.darwin;
  };
})

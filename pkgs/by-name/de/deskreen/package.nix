{
  lib,
  fetchurl,
  appimageTools,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deskreen";
  version = "2.0.4";

  src = fetchurl {
    url = "https://github.com/pavlobu/deskreen/releases/download/v${finalAttrs.version}/Deskreen-${finalAttrs.version}.AppImage";
    hash = "sha256-0jI/mbXaXanY6ay2zn+dPWGvsqWRcF8aYHRvfGVsObE=";
  };

  buildInputs = [
    finalAttrs.deskreenUnwrapped
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s ${finalAttrs.deskreenUnwrapped}/bin/deskreen $out/bin/deskreen

    runHook postInstall
  '';

  deskreenUnwrapped = appimageTools.wrapType2 {
    inherit (finalAttrs) pname version;
    src = finalAttrs.src;
  };

  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "Turn any device into a secondary screen for your computer";
    homepage = "https://deskreen.com";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      leo248
    ];

    platforms = lib.platforms.linux;
    mainProgram = "deskreen";
  };
})

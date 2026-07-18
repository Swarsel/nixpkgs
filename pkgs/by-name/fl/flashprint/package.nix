{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  libGLU,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flashprint";
  version = "5.8.7";

  src = fetchurl {
    url = "http://www.ishare3d.com/3dapp/public/FlashPrint-5/FlashPrint/flashprint5_${finalAttrs.version}_amd64.deb";
    hash = "sha256-DVY5XxAz3HPAWMNaGauUop7OWHeFuuRHuVllyJvHqFk=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libGLU
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv etc usr/* $out
    ln -s $out/share/FlashPrint5/FlashPrint $out/bin/flashprint
    sed -i "/^Exec=/ c Exec=$out/bin/flashprint" $out/share/applications/FlashPrint5.desktop

    runHook postInstall
  '';

  qtWrapperArgs = [ "--prefix QT_QPA_PLATFORM : xcb" ];

  meta = {
    description = "Slicer for the FlashForge 3D printers";
    homepage = "https://www.flashforge.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.ianliu ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "flashprint";
  };
})

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  gtk3-x11,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "pixeluvo";
  version = "1.6.0-2";

  src = fetchurl {
    url = "http://www.pixeluvo.com/downloads/${pname}_${version}_amd64.deb";
    sha256 = "sha256-QYSuD6o3kHg0DrFihYEcf9e3b8U1bu4Zf78+Akmm8yo=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    gtk3-x11
    stdenv.cc.cc
  ];

  installPhase = ''
    runHook preInstall

    mv usr $out
    mv opt $out
    install -Dm644 $out/opt/pixeluvo/pixeluvo.png -t $out/share/icons/hicolor/48x48/apps

    substituteInPlace $out/share/applications/pixeluvo.desktop \
      --replace '/opt/pixeluvo/pixeluvo.png' pixeluvo

    makeWrapper $out/opt/pixeluvo/bin/Pixeluvo64 $out/bin/pixeluvo \
      --prefix LD_LIBRARY_PATH : ${libPath}

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  libPath = lib.makeLibraryPath buildInputs;

  meta = {
    description = "Beautifully Designed Image and Photo Editor for Windows and Linux";
    homepage = "http://www.pixeluvo.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "pixeluvo";
  };
}

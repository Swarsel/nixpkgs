{
  lib,
  stdenv,
  imagemagick,
  inkscape,
  qt5,
  wpa_supplicant,
}:

stdenv.mkDerivation {
  inherit (wpa_supplicant) version src patches;
  pname = "wpa_gui";

  postPatch = ''
    cd wpa_supplicant/wpa_gui-qt4
  '';

  nativeBuildInputs = [
    qt5.qmake
    inkscape
    imagemagick
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
  ];

  postBuild = ''
    make -C icons
  '';

  postInstall = ''
    mkdir -pv $out/{bin,share/applications,share/icons}
    cp -v wpa_gui $out/bin
    cp -v wpa_gui.desktop $out/share/applications
    cp -av icons/hicolor $out/share/icons
  '';

  meta = {
    description = "Qt-based GUI for wpa_supplicant";
    homepage = "https://hostap.epitest.fi/wpa_supplicant/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "wpa_gui";
  };
}

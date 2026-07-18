{
  lib,
  stdenv,
  fetchurl,
  libsForQt5,
}:

stdenv.mkDerivation rec {
  pname = "confclerk";
  version = "0.7.2";

  src = fetchurl {
    url = "https://www.toastfreeware.priv.at/tarballs/confclerk/confclerk-${version}.tar.gz";
    sha256 = "sha256-GgWvPHcQnQrK9SOC8U9F2P8kuPCn8I2EhoWEEMtKBww=";
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [ libsForQt5.qtbase ];

  postInstall = ''
    mkdir -p $out/bin
    mv $out/confclerk $out/bin/
  '';

  meta = {
    description = "Offline conference schedule viewer";
    homepage = "http://www.toastfreeware.priv.at/confclerk";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "confclerk";
  };
}

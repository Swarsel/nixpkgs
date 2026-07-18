{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  c-ares,
  ffmpeg,
  libappindicator,
  libappindicator-gtk3,
  libevent,
  libgbm,
  libnotify,
  libvpx,
  libxdamage,
  libxscrnsaver,
  libxslt,
  libxtst,
  makeWrapper,
  minizip,
  nss,
  re2,
  snappy,
  udev,
}:

stdenv.mkDerivation rec {
  pname = "tetrd";
  version = "1.0.4";

  src = fetchurl {
    url = "https://web.archive.org/web/20211130190525/https://download.tetrd.app/files/tetrd.linux_amd64.pkg.tar.xz";
    sha256 = "1bxp7rg2dm9nnvkgg48xd156d0jgdf35flaw0bwzkkh3zz9ysry2";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    c-ares
    ffmpeg
    libevent
    libvpx
    libxslt
    libxscrnsaver
    libxdamage
    libxtst
    minizip
    nss
    re2
    snappy
    libnotify
    libappindicator-gtk3
    libappindicator
    udev
    libgbm
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -r $sourceRoot/opt/Tetrd $out/opt
    cp -r $sourceRoot/usr/share $out

    wrapProgram $out/opt/Tetrd/tetrd \
      --prefix LD_LIBRARY_PATH ":" ${lib.makeLibraryPath buildInputs}

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/tetrd.desktop --replace /opt $out/opt
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  meta = {
    description = "Share your internet connection from your device to your PC and vice versa through a USB cable";
    homepage = "https://tetrd.app";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}

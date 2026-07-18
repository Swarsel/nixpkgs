{
  lib,
  stdenv,
  fetchurl,
  # QQ Music dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  cups,
  dbus,
  dpkg,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdbusmenu,
  libglvnd,
  libpulseaudio,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nspr,
  nss,
  pango,
  pciutils,
  udev,
}:
################################################################################
# Mostly based on qqmusic-bin package from AUR:
# https://aur.archlinux.org/packages/qqmusic-bin
################################################################################
stdenv.mkDerivation (finalAttrs: {
  pname = "qqmusic";
  version = "1.1.8";

  src = fetchurl {
    url = "https://c.y.qq.com/cgi-bin/file_redirect.fcg?bid=dldir&file=ecosfile_plink%2Fmusic_clntupate%2Flinux%2Fother%2Fqqmusic_${finalAttrs.version}_amd64.deb&sign=1-d1ca4d5c5a8369b26af88e881ba3ac544066a899dcaea29778b35c9f648e6fee-68cb7c1c";
    hash = "sha256-QtGNaow8F0FOW228DDrIk7slQMHFwJzpDSQYQ8xZN4g=";
    name = "qqmusic.deb";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    dpkg
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdbusmenu
    libglvnd
    libpulseaudio
    nspr
    nss
    pango
    pciutils
    udev
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r opt/qqmusic $out/opt
    cp -r usr/* $out/

    rm -rf $out/opt/swiftshader
    ln -sf ${libglvnd}/lib $out/opt/swiftshader

    mkdir -p $out/bin
    makeWrapper $out/opt/qqmusic $out/bin/qqmusic \
      --argv0 "qqmusic" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "AudioVideo" ];
      comment = "Tencent QQMusic";
      desktopName = "QQMusic";
      exec = "qqmusic %U";

      extraConfig = {
        "Comment[zh_CN]" = "腾讯QQ音乐";
        "Comment[zh_TW]" = "騰訊QQ音樂";
        "Name[zh_CN]" = "QQ音乐";
        "Name[zh_TW]" = "QQ音樂";
      };

      icon = "qqmusic";
      name = "qqmusic";
      startupWMClass = "qqmusic";
      terminal = false;
    })
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg -x $src .

    runHook postUnpack
  '';

  meta = {
    description = "Tencent QQ Music";
    homepage = "https://y.qq.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "qqmusic";
  };
})

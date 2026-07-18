{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  dbus,
  dpkg,
  fontconfig,
  freetype,
  glib,
  gst_all_1,
  libGL,
  libgbm,
  libinput,
  libpulseaudio,
  libsecret,
  libtiff,
  libx11,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxkbcommon,
  makeWrapper,
  openssl,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alfaview";
  version = "9.24.1";

  src = fetchurl {
    url = "https://assets.alfaview.com/stable/linux/deb/alfaview_${finalAttrs.version}.deb";
    hash = "sha256-vRo5ZD3yYTWhR6fbc/HFtBBbYuq3cGbxPuDlSt5D8XM=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    dbus
    fontconfig
    freetype
    glib
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-base
    libGL
    libinput
    libpulseaudio
    libsecret
    libtiff
    libxkbcommon
    libgbm
    openssl
    stdenv.cc.cc
    systemd
    libxcb-cursor
    libx11
    libxcb-wm
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
  ];

  installPhase = ''
    runHook preInstall

    mv usr $out
    mv opt $out

    substituteInPlace $out/share/applications/alfaview.desktop \
      --replace-fail "/opt/alfaview" "$out/bin" \
      --replace-fail "/usr/share/pixmaps/alfaview.png" alfaview

    makeWrapper $out/opt/alfaview/alfaview $out/bin/alfaview \
      --prefix LD_LIBRARY_PATH : ${finalAttrs.libPath}

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  libPath = lib.makeLibraryPath finalAttrs.buildInputs;

  meta = {
    description = "Video-conferencing application, specialized in virtual online meetings, seminars, training sessions and conferences";
    homepage = "https://alfaview.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "alfaview";
  };
})

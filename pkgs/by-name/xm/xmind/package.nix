{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  glib,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  nspr,
  nss,
  pango,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xmind";
  version = "26.01.03145-202510170359";

  src = fetchurl {
    url = "https://dl3.xmind.app/Xmind-for-Linux-amd64bit-${finalAttrs.version}.deb";
    hash = "sha256-h7qxDf219+t8oAk8IABs7MyasNd3K/PAM6a79kyaLdw=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    libx11
    libxext
    libxcb
    libxcomposite
    libxdamage
    libxfixes
    libxrandr
    libxkbfile
    glib
    at-spi2-atk
    cairo
    pango
    gtk3
    nss
    nspr
    cups
    dbus
    libdrm
    libxkbcommon
    alsa-lib
    expat
    libgbm
  ];

  installPhase = ''
    runHook preInstall

    substituteInPlace usr/share/applications/xmind.desktop \
      --replace-fail "/opt/Xmind/xmind" "xmind"
    cp -r usr $out
    mkdir -p $out/opt $out/bin
    cp -r opt/Xmind $out/opt/xmind
    ln -s $out/opt/xmind/xmind $out/bin/xmind

    runHook postInstall
  '';

  preFixup = ''
    patchelf --add-needed libGL.so.1 \
      --add-rpath ${
        lib.makeLibraryPath [
          libGL
        ]
      } $out/opt/xmind/xmind
  '';

  runtimeDependencies = map lib.getLib [
    systemd
  ];

  meta = {
    description = "All-in-one thinking tool featuring mind mapping, AI generation, and real-time collaboration";
    homepage = "https://xmind.app";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ michalrus ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "xmind";
  };
})

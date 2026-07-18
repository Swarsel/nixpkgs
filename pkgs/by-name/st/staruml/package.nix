{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  bintools,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  hicolor-icon-theme,
  libGL,
  libdrm,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxshmfence,
  libxtst,
  nspr,
  nss,
  pango,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "staruml";
  version = "7.0.0";

  src = fetchurl {
    url = "https://files.staruml.io/releases-v7/StarUML_${finalAttrs.version}_amd64.deb";
    hash = "sha256-z25qeE2G9F010IE1WFxwIifYqowjB4dpUDgRg38RtQc=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    dpkg
  ];

  buildInputs = [
    glib
    hicolor-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv opt $out

    mv usr/share $out
    rm -rf $out/share/doc

    substituteInPlace $out/share/applications/staruml.desktop \
      --replace-fail "/opt/StarUML/staruml" "$out/bin/staruml"

    mkdir -p $out/lib
    ln -s ${lib.getLib stdenv.cc.cc}/lib/libstdc++.so.6 $out/lib/
    ln -s ${lib.getLib systemd}/lib/libudev.so.1 $out/lib/libudev.so.0

    patchelf --interpreter ${bintools.dynamicLinker} --add-needed libGL.so.1 $out/opt/StarUML/staruml

    ln -s $out/opt/StarUML/staruml $out/bin/staruml

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : $out/lib:${
        lib.makeLibraryPath [
          glib
          gtk3
          libxdamage
          libx11
          libxcb
          libxcomposite
          libxcursor
          libxext
          libxfixes
          libxi
          libxrender
          libxtst
          libxshmfence
          libxkbcommon
          nss
          nspr
          atk
          at-spi2-atk
          dbus
          gdk-pixbuf
          pango
          cairo
          libxrandr
          expat
          libdrm
          libgbm
          alsa-lib
          at-spi2-core
          cups
          libGL
        ]
      }
    )
  '';

  meta = {
    description = "Sophisticated software modeler";
    homepage = "https://staruml.io/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ kashw2 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "staruml";
  };
})

{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  atk,
  autoPatchelfHook,
  cups,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libsecret,
  libx11,
  libxcb,
  libxext,
  libxkbcommon,
  makeBinaryWrapper,
  pango,
  sqlite,
  squashfsTools,
  systemd,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tradingview";
  version = "3.2.0";

  src = fetchurl {
    url = "https://api.snapcraft.io/api/v1/snaps/download/nJdITJ6ZJxdvfu8Ch7n5kH5P99ClzBYV_${finalAttrs.revision}.snap";
    hash = "sha512-hT4U+RGqZ4OliAiLqWKkuv/OxeOpKHmFY0/ia9V7MZz1ZhogIaCLUUXXCmlfX1zhQDA1Xrw1uiwl/aeijgdq7g==";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
    squashfsTools
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    atk
    at-spi2-atk
    cups
    gtk3
    libdrm
    libsecret
    libxkbcommon
    libgbm
    libGL
    pango
    sqlite
    systemd
    wayland
    libxcb
    libx11
    libxext
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r squashfs-root $out/share/tradingview
    rm -rf $out/share/tradingview/meta
    substituteInPlace squashfs-root/meta/gui/tradingview.desktop \
      --replace-fail \$\{SNAP}/meta/gui/icon.png tradingview
    install -D --mode 644 squashfs-root/meta/gui/tradingview.desktop -t $out/share/applications
    install -D --mode 644 squashfs-root/meta/gui/icon.png $out/share/icons/hicolor/512x512/apps/tradingview.png
    mkdir $out/bin
    makeWrapper $out/share/tradingview/tradingview $out/bin/tradingview \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs}

    runHook postInstall
  '';

  preFixup = ''
    patchelf --add-needed libGL.so.1 $out/share/tradingview/tradingview
  '';

  revision = "71";

  unpackPhase = ''
    runHook preUnpack

    unsquashfs $src

    runHook postUnpack
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Charting platform for traders and investors";
    homepage = "https://www.tradingview.com/desktop/";
    changelog = "https://www.tradingview.com/support/solutions/43000673888/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tradingview";
  };
})

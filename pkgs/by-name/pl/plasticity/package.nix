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
  desktop-file-utils,
  expat,
  gdk-pixbuf,
  gtk3,
  gvfs,
  hicolor-icon-theme,
  libGL,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxtst,
  nspr,
  nss,
  openssl,
  pango,
  rpmextract,
  systemd,
  trash-cli,
  vulkan-loader,
  wrapGAppsHook3,
  xdg-utils,
}:
stdenv.mkDerivation rec {
  pname = "plasticity";
  version = "26.1.3";

  src = fetchurl {
    url = "https://github.com/nkallen/plasticity/releases/download/v${version}/Plasticity-${version}-1.x86_64.rpm";
    hash = "sha256-gHoih3CldhrHPLBpu3slRUxJSBIbYYhQ9WhEbhjHzyM=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    rpmextract
    libgbm
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    desktop-file-utils
    expat
    gdk-pixbuf
    gtk3
    gvfs
    hicolor-icon-theme
    libdrm
    libnotify
    libxkbcommon
    nspr
    nss
    openssl
    pango
    (lib.getLib stdenv.cc.cc)
    trash-cli
    xdg-utils
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cd $out
    rpmextract $src
    mv $out/usr/* $out
    rm -r $out/usr
    rm -r $out/lib/.build-id

    runHook postInstall
  '';

  preFixup = ''
    patchelf --add-needed libGL.so.1 \
      --set-rpath "${
        lib.makeLibraryPath [
          libGL
        ]
      }" \
      $out/bin/Plasticity

    rm "$out/lib/Plasticity/libvulkan.so.1"
    ln -s -t "$out/lib/Plasticity" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"
  '';

  # can't find anything on the internet about these files, no clue what they do
  autoPatchelfIgnoreMissingDeps = [
    "ACCAMERA.tx"
    "AcMPolygonObj15.tx"
    "ATEXT.tx"
    "ISM.tx"
    "RText.tx"
    "SCENEOE.tx"
    "TD_DbEntities.tx"
    "TD_DbIO.tx"
    "WipeOut.tx"
  ];

  dontUnpack = true;

  runtimeDependencies = [
    systemd
    libglvnd
    vulkan-loader # may help with nvidia users
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxtst
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "CAD for artists";
    homepage = "https://www.plasticity.xyz";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      imadnyc
      bearfm
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "Plasticity";
  };
}

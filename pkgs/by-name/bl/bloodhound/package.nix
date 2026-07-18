{
  lib,
  stdenv,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fetchzip,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libappindicator-gtk3,
  libdrm,
  libgbm,
  libnotify,
  libpulseaudio,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  systemd,
  udev,
  unzip,
  xdg-utils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bloodhound";
  version = "4.3.1";

  src = fetchzip {
    url = "https://github.com/SpecterOps/BloodHound-Legacy/releases/download/v${finalAttrs.version}/BloodHound-linux-x64.zip";
    hash = "sha256-gGfZ5Mj8rmz3dwKyOitRExkgOmSVDOqKpPxvGlE4izw=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  buildInputs = [
    gtk3 # needed for GSETTINGS_SCHEMAS_PATH
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,/lib/BloodHound}
    mv * $out/lib/BloodHound
    chmod +x $out/lib/BloodHound/BloodHound

    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
       $out/lib/BloodHound/BloodHound --set-rpath ${finalAttrs.rpath}:$out/lib/BloodHound \
       --add-needed libudev.so # Needed to fix trace trap (core dump)

    makeWrapper $out/lib/BloodHound/BloodHound $out/bin/BloodHound \
      --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --append-flags "--in-process-gpu" # fix for sandbox issues

    runHook postInstall
  '';

  dontBuild = true;

  rpath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libappindicator-gtk3
    libdrm
    libnotify
    libpulseaudio
    libuuid
    libxcb
    libxkbcommon
    libgbm
    nspr
    nss
    pango
    systemd
    (lib.getLib stdenv.cc.cc)
    udev
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxkbfile
    libxshmfence
  ];

  meta = {
    description = "Active Directory reconnaissance and attack path management tool";
    homepage = "https://github.com/SpecterOps/BloodHound-Legacy";
    changelog = "https://github.com/SpecterOps/BloodHound-Legacy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ akechishiro ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "BloodHound";
    downloadPage = "https://github.com/SpecterOps/BloodHound-Legacy/releases";
  };
})

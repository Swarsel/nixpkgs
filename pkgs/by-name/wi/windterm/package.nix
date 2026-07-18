{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  atk,
  autoPatchelfHook,
  cairo,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk3,
  libGL,
  libsForQt5,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxtst,
  makeWrapper,
  pango,
  pulseaudio,
  unzip,
  profiles ? {
    path = "~";
  },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "windterm";
  version = "2.7.0";

  src = fetchurl {
    url = "https://github.com/kingToolbox/WindTerm/releases/download/${finalAttrs.version}/WindTerm_${finalAttrs.version}_Linux_Portable_x86_64.zip";
    hash = "sha256-d5dpfutgI5AgUS4rVJaVpgw5s/0B/n67BH/VCiiJEDw=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    libxcb
    libxcb-util
    libxtst
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libsForQt5.qtbase
    libsForQt5.qtmultimedia
    gst_all_1.gst-plugins-base
    fontconfig
    freetype
    libGL
    glib
    alsa-lib
    pulseaudio
    gtk3
    atk
    pango
    gdk-pixbuf
    cairo
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/app $out/share/applications $out/share/licenses/windterm
    cp --recursive --no-preserve=mode . $out/app/windterm
    cat > $out/app/windterm/profiles.config <<EOF
    ${builtins.toJSON profiles}
    EOF
    install -Dm644 $out/app/windterm/license.txt $out/share/licenses/windterm/license.txt
    install -Dm644 $out/app/windterm/windterm.png -t $out/share/icons
    substituteInPlace $out/app/windterm/windterm.desktop \
      --replace-fail "/usr/bin/" ""
    install -Dm644 $out/app/windterm/windterm.desktop $out/share/applications/windterm.desktop
    chmod +x $out/app/windterm/WindTerm

    runHook postInstall
  '';

  postFixup = ''
    mkdir $out/bin
    makeWrapper $out/app/windterm/WindTerm $out/bin/windterm \
      --prefix QT_PLUGIN_PATH : $out/app/windterm/lib \
      ''${qtWrapperArgs[@]}
  '';

  dontBuild = true;
  dontWrapQtApps = true;

  meta = {
    description = "Professional cross-platform SSH/Sftp/Shell/Telnet/Serial terminal";
    homepage = "https://github.com/kingToolbox/WindTerm";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "windterm";
  };
})

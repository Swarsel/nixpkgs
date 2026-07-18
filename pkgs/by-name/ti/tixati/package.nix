{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cairo,
  dbus,
  dbus-glib,
  gdk-pixbuf,
  glib,
  gtk3,
  pango,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tixati";
  version = "3.44";

  src = fetchurl {
    url = "https://download.tixati.com/tixati-${finalAttrs.version}-1.x86_64.manualinstall.tar.gz";
    hash = "sha256-OwYAGaSOt6m3vQFGCszrxAeeGjEF6nfsZszXvJX4kR8=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    zlib
    dbus
    glib
    gtk3
    pango
    gdk-pixbuf
    dbus-glib
    cairo
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 tixati $out/bin/tixati
    install -Dm644 tixati.png -t $out/share/icons/hicolor/48x48/apps
    install -Dm644 tixati.desktop $out/share/applications/tixati.desktop

    runHook postInstall
  '';

  sourceRoot = "tixati-${finalAttrs.version}-1.x86_64.manualinstall";

  meta = {
    description = "Simple and Easy to Use Bittorrent Client";
    homepage = "https://www.tixati.com/";
    changelog = "https://tixati.com/news";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ FlorisMenninga ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tixati";
    downloadPage = "https://tixati.com/linux";
  };
})

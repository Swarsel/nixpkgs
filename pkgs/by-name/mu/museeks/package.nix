{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cairo,
  dbus,
  dpkg,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk3,
  libsoup_3,
  nix-update-script,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "museeks";
  version = "0.23.4";

  src = fetchurl {
    url = "https://github.com/martpie/museeks/releases/download/${finalAttrs.version}/Museeks_${finalAttrs.version}_amd64.deb";
    hash = "sha256-2WkWBd4opWpCcjE+uWRbDC8RPQoVvflpxbWuuNF2Z54=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus
    webkitgtk_4_1
    libsoup_3
    gtk3
    cairo
    gdk-pixbuf
    glib
    (lib.getLib stdenv.cc.cc)
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  installPhase = ''
    runHook preInstall

    cp -r usr $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple, clean and cross-platform music player";
    homepage = "https://github.com/martpie/museeks";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "museeks";
  };
})

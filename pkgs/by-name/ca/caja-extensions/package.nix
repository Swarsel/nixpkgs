{
  lib,
  stdenv,
  fetchurl,
  caja,
  gettext,
  gitUpdater,
  glib,
  gst_all_1,
  gtk3,
  gupnp_1_6,
  imagemagick,
  mate-desktop,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "caja-extensions";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/caja-extensions-${finalAttrs.version}.tar.xz";
    sha256 = "0phsXgdAg1/icc+9WCPu6vAyka8XYyA/RwCruBCeMXU=";
  };

  postPatch = ''
    for f in image-converter/caja-image-{resizer,rotator}.c; do
      substituteInPlace $f --replace-fail 'argv[0] = "convert"' 'argv[0] = "${imagemagick}/bin/convert"'
    done
  '';

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    caja
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk3
    gupnp_1_6
    imagemagick
    mate-desktop
  ];

  configureFlags = [ "--with-cajadir=$$out/lib/caja/extensions-2.0" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/caja-extensions";
  };

  meta = {
    description = "Set of extensions for Caja file manager";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "caja-sendto";
    teams = [ lib.teams.mate ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  gtk-layer-shell,
  gtk3,
  libcanberra-gtk3,
  libmatemixer,
  libtool,
  libxml2,
  mate-desktop,
  mate-panel,
  pkg-config,
  wayland,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-media";
  version = "1.28.1";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-media-${finalAttrs.version}.tar.xz";
    sha256 = "vNwQLiL2P1XmMWbVxwjpHBE1cOajCodDRaiGCeg6mRI=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    libtool
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk-layer-shell
    gtk3
    libcanberra-gtk3
    libmatemixer
    libxml2
    mate-desktop
    mate-panel
    wayland
  ];

  configureFlags = [ "--enable-in-process" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-media";
  };

  meta = {
    description = "Media tools for MATE";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ chpatrick ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})

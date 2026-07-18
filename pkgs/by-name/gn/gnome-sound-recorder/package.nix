{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  gjs,
  glib,
  gnome,
  gobject-introspection,
  gst_all_1,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-sound-recorder";
  version = "43.beta";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-sound-recorder/${lib.versions.major finalAttrs.version}/gnome-sound-recorder-${finalAttrs.version}.tar.xz";
    hash = "sha256-bbbbmjsbUv0KtU+aW/Tymctx5SoTrF/fw+dOtGmFpOY=";
  };

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    substituteInPlace build-aux/meson_post_install.py \
      --replace-fail 'gtk-update-icon-cache' 'gtk4-update-icon-cache'
    patchShebangs build-aux/meson_post_install.py
  '';

  nativeBuildInputs = [
    pkg-config
    gettext
    meson
    ninja
    gobject-introspection
    wrapGAppsHook4
    python3
    desktop-file-utils
  ];

  buildInputs = [
    gjs
    glib
    gtk4
    gdk-pixbuf
    libadwaita
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad # for gstreamer-player-1.0
  ]);

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-sound-recorder"; };
  };

  meta = {
    description = "Simple and modern sound recorder";
    homepage = "https://gitlab.gnome.org/World/vocalis";
    changelog = "https://gitlab.gnome.org/World/vocalis/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-sound-recorder";
    teams = [ lib.teams.gnome ];
  };
})

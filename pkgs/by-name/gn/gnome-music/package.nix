{
  lib,
  fetchurl,
  appstream-glib,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  glib,
  gnome,
  gnome-online-accounts,
  gobject-introspection,
  grilo,
  grilo-plugins,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk4,
  itstool,
  libadwaita,
  libmediaart,
  libnotify,
  libsoup_3,
  libxml2,
  meson,
  ninja,
  pango,
  pkg-config,
  python3,
  tinysparql,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gnome-music";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-music/${lib.versions.major finalAttrs.version}/gnome-music-${finalAttrs.version}.tar.xz";
    hash = "sha256-xyiQyn5YCc7+uHawEZn4sZcUa1wl6dV0UwGihMDzzao=";
  };

  # handle setup hooks better
  strictDeps = false;

  nativeBuildInputs = [
    meson
    ninja
    gettext
    itstool
    pkg-config
    libxml2
    wrapGAppsHook4
    desktop-file-utils
    appstream-glib
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    pango
    glib
    libmediaart
    gnome-online-accounts
    gdk-pixbuf
    python3
    grilo
    grilo-plugins
    libnotify
    libsoup_3
    libadwaita
    gsettings-desktop-schemas
    tinysparql
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ]);

  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # Prevent double wrapping, let the Python wrapper use the args in preFixup.
  dontWrapGApps = true;
  pyproject = false;

  pythonPath = with python3.pkgs; [
    pycairo
    dbus-python
    pygobject3
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-music"; };
  };

  meta = {
    description = "Music player and management application for the GNOME desktop environment";
    homepage = "https://apps.gnome.org/Music/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-music";
    teams = [ lib.teams.gnome ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  gjs,
  glib,
  glib-networking,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gspell,
  gtk3,
  gtk4,
  itstool,
  libadwaita,
  libsecret,
  libsoup_3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  telepathy-glib,
  telepathy-idle,
  telepathy-mission-control,
  tinysparql,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "polari";
  version = "49.0";

  src = fetchurl {
    url = "mirror://gnome/sources/polari/${lib.versions.major finalAttrs.version}/polari-${finalAttrs.version}.tar.xz";
    hash = "sha256-UmJv3jkJkhrFhsxMwQ8w8SOq9hVaF374hhyg5V1t6FA=";
  };

  patches = [
    # Upstream runs the thumbnailer by passing it to gjs.
    # If we wrap it in a shell script, gjs can no longer run it.
    # Let’s change the code to run the script directly by making it executable and having gjs in shebang.
    ./make-thumbnailer-wrappable.patch

    # fix TypeError: (intermediate value).get_current_event_device is not a function
    # https://gitlab.gnome.org/GNOME/polari/-/merge_requests/320
    ./0001-joinDialog-Fix-detecting-pointer-devices.patch

    # https://gitlab.gnome.org/GNOME/polari/-/merge_requests/329
    ./0002-mainWindow-Disconnect-event-handler-on-destroy.patch

    # https://gitlab.gnome.org/GNOME/polari/-/merge_requests/330
    ./0003-Add-option-to-disable-URL-preview-feature.patch

    # This also helps us to distribute the app as a single package
    # without enabling telepathy-{idle,mission-control} services
    ./check_dbus_unconditionally.patch

    # This fixes Tracker.SparqlError: table Resource already exists
    # and chat history spinning forever on second launch.
    # Fixes the race condition by ensuring all callers wait on the
    # same shared initialization promise
    ./fix_sparql_database_race.patch
  ];

  postPatch = ''
    substituteInPlace src/application.js \
      --replace-fail "/app/libexec/mission-control-5" "${lib.getLib telepathy-mission-control}/libexec/mission-control-5" \
      --replace-fail "/app/libexec/telepathy-idle" "${telepathy-idle}/libexec/telepathy-idle"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    itstool
    gettext
    wrapGAppsHook4
    libxml2
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    tinysparql
    libadwaita
    gtk3 # for thumbnailer
    glib
    glib-networking
    gsettings-desktop-schemas
    telepathy-glib
    gjs
    gspell
    gdk-pixbuf
    libsecret
    libsoup_3
    webkitgtk_4_1 # for thumbnailer
  ];

  postFixup = ''
    wrapGApp "$out/share/polari/thumbnailer.js"
  '';

  passthru = {
    updateScript = gnome.updateScript { packageName = "polari"; };
  };

  meta = {
    description = "IRC chat client designed to integrate with the GNOME desktop";
    homepage = "https://apps.gnome.org/Polari/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "polari";

    teams = [
      lib.teams.gnome
      lib.teams.gnome-circle
    ];
  };
})

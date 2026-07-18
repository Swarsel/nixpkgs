{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gdk-pixbuf,
  geoclue2,
  geocode-glib_2,
  gettext,
  glib,
  gnome,
  gnome-desktop,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk4,
  icu,
  itstool,
  libadwaita,
  libgweather,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  vorbis-tools,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-clocks";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-clocks/${lib.versions.major finalAttrs.version}/gnome-clocks-${finalAttrs.version}.tar.xz";
    hash = "sha256-vxZ/f0T08vtCTUcWZSybofKeFuSQceJqG7gz+NznlMY=";
  };

  nativeBuildInputs = [
    vala
    vorbis-tools
    meson
    ninja
    pkg-config
    gettext
    itstool
    wrapGAppsHook4
    desktop-file-utils
    libxml2
  ];

  buildInputs = [
    gtk4
    glib
    gsettings-desktop-schemas
    gdk-pixbuf
    gnome-desktop
    geocode-glib_2
    geoclue2
    icu
    libgweather
    libadwaita
  ]
  ++ (with gst_all_1; [
    # GStreamer plugins needed for Alarms
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]);

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-clocks"; };
  };

  meta = {
    description = "Simple and elegant clock application for GNOME";

    longDescription = ''
      A simple and elegant clock application. It includes world clocks, alarms,
      a stopwatch, and timers.

      - Show the time in different cities around the world
      - Set alarms to wake you up
      - Measure elapsed time with an accurate stopwatch
      - Set timers to properly cook your food
    '';

    homepage = "https://apps.gnome.org/Clocks/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-clocks";
    teams = [ lib.teams.gnome ];
  };
})

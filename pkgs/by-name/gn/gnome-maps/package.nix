{
  lib,
  stdenv,
  fetchurl,
  blueprint-compiler,
  desktop-file-utils,
  gdk-pixbuf,
  geoclue2,
  geocode-glib_2,
  gettext,
  gjs,
  glib,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  libadwaita,
  libgweather,
  libportal,
  librest,
  libsecret,
  libshumate,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  tzdata,
  wrapGAppsHook4,
  writeText,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-maps";
  version = "50.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-maps/${lib.versions.major finalAttrs.version}/gnome-maps-${finalAttrs.version}.tar.xz";
    hash = "sha256-KKRGfR7J/jjrf4YmdMGZ6IQIbiXkwLDYDrUEVoICzr8=";
  };

  postPatch = ''
    # The .service file isn't wrapped with the correct environment
    # so misses GIR files when started. By re-pointing from the gjs
    # entry point to the wrapped binary we get back to a wrapped
    # binary.
    substituteInPlace "data/org.gnome.Maps.service.in" \
      --replace-fail "Exec=@pkgdatadir@/@app-id@" \
                     "Exec=$out/bin/gnome-maps"
  '';

  nativeBuildInputs = [
    blueprint-compiler
    gettext
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gobject-introspection
    # For post install script
    desktop-file-utils
    glib
    gtk4
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    geoclue2
    geocode-glib_2
    gjs
    gsettings-desktop-schemas
    gtk4
    libportal
    libshumate
    libgweather
    libadwaita
    librest
    libsecret
    libsoup_3
  ];

  mesonFlags = [
    "--cross-file=${writeText "crossfile.ini" ''
      [binaries]
      gjs = '${lib.getExe gjs}'
    ''}"
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  preCheck = ''
    # “time.js” included by “timeTest” and “translationsTest” depends on “org.gnome.desktop.interface” schema.
    export XDG_DATA_DIRS="${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:$XDG_DATA_DIRS"
    export HOME=$(mktemp -d)
    export TZDIR=${tzdata}/share/zoneinfo

    # Our gobject-introspection patches make the shared library paths absolute
    # in the GIR files. When running tests, the library is not yet installed,
    # though, so we need to replace the absolute path with a local one during build.
    # We are using a symlink that we will delete before installation.
    mkdir -p $out/lib/gnome-maps
    ln -s $PWD/lib/libgnome-maps.so.0 $out/lib/gnome-maps/libgnome-maps.so.0
  '';

  postCheck = ''
    rm $out/lib/gnome-maps/libgnome-maps.so.0
  '';

  preFixup = ''
    substituteInPlace "$out/share/applications/org.gnome.Maps.desktop" \
      --replace-fail "Exec=gapplication launch org.gnome.Maps" \
                     "Exec=gnome-maps"
  '';

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-maps"; };
  };

  meta = {
    description = "Map application for GNOME 3";
    homepage = "https://apps.gnome.org/Maps/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-maps";
    teams = [ lib.teams.gnome ];
  };
})

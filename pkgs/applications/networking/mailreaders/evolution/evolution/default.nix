{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  bogofilter,
  cmake,
  cmark,
  db,
  evolution-data-server,
  gdk-pixbuf,
  geocode-glib_2,
  glib,
  glib-networking,
  gnome,
  gnome-desktop,
  gnutar,
  gsettings-desktop-schemas,
  gspell,
  gst_all_1,
  gtk3,
  gzip,
  highlight,
  icu,
  intltool,
  itstool,
  libcanberra-gtk3,
  libgweather,
  libical,
  libnotify,
  libpst,
  librsvg,
  libsecret,
  libxml2,
  ninja,
  nspr,
  nss,
  openldap,
  p11-kit,
  pkg-config,
  procps,
  shared-mime-info,
  spamassassin,
  sqlite,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "evolution";
  version = "3.60.2";

  src = fetchurl {
    url = "mirror://gnome/sources/evolution/${lib.versions.majorMinor finalAttrs.version}/evolution-${finalAttrs.version}.tar.xz";
    hash = "sha256-IYpJ+lBoFV29vTWjDRCi8jfHJGX7HQ4Kp4iJ8DnC7Y8=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    intltool
    itstool
    libxml2
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    adwaita-icon-theme
    bogofilter
    db
    evolution-data-server
    gdk-pixbuf
    glib
    glib-networking
    gnome-desktop
    gsettings-desktop-schemas
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    gtk3
    gspell
    highlight
    icu
    libcanberra-gtk3
    geocode-glib_2
    cmark
    libgweather
    libical
    libnotify
    libpst
    librsvg
    libsecret
    nspr
    nss
    openldap
    p11-kit
    procps
    shared-mime-info
    sqlite
    webkitgtk_4_1
  ];

  cmakeFlags = [
    "-DENABLE_AUTOAR=OFF"
    "-DENABLE_YTNEF=OFF"
    "-DWITH_SPAMASSASSIN=${spamassassin}/bin/spamassassin"
    "-DWITH_SA_LEARN=${spamassassin}/bin/sa-learn"
    "-DWITH_BOGOFILTER=${bogofilter}/bin/bogofilter"
    "-DWITH_OPENLDAP=${openldap}"
  ];

  env = {
    PKG_CONFIG_CAMEL_1_2_CAMEL_PROVIDERDIR = "${placeholder "out"}/lib/evolution-data-server/camel-providers";
    PKG_CONFIG_LIBEDATASERVERUI_1_2_UIMODULEDIR = "${placeholder "out"}/lib/evolution-data-server/ui-modules";
  };

  doCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${
        lib.makeBinPath [
          gnutar
          gzip
          xz
        ]
      }"
    )
  '';

  propagatedUserEnvPkgs = [
    evolution-data-server
  ];

  requiredSystemFeatures = [
    "big-parallel"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "evolution";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Personal information management application that provides integrated mail, calendaring and address book functionality";
    homepage = "https://gitlab.gnome.org/GNOME/evolution";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "evolution";
    teams = [ lib.teams.gnome ];
  };
})

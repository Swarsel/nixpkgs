{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  cacert,
  dbus,
  desktop-file-utils,
  enchant,
  folks,
  gcr,
  gettext,
  glib-networking,
  glibcLocales,
  gmime3,
  gnome,
  gnome-online-accounts,
  gnutls,
  gobject-introspection,
  gsettings-desktop-schemas,
  gsound,
  gspell,
  gtk3,
  icu,
  isocodes,
  itstool,
  json-glib,
  libgee,
  libhandy,
  libpeas,
  libsecret,
  libstemmer,
  libunwind,
  libxml2,
  libytnef,
  meson,
  ninja,
  pkg-config,
  python3,
  shared-mime-info,
  sqlite,
  vala,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geary";
  version = "46.0";

  src = fetchurl {
    url = "mirror://gnome/sources/geary/${lib.versions.major finalAttrs.version}/geary-${finalAttrs.version}.tar.xz";
    hash = "sha256-r60VEwKBfd8Ji15BbnrH8tXupWejuAu5C9PGKv0TuaE=";
  };

  postPatch = ''
    chmod +x build-aux/git_version.py

    patchShebangs build-aux/git_version.py

    # Only used for generating .pot file
    # https://gitlab.gnome.org/GNOME/geary/-/merge_requests/856
    substituteInPlace meson.build \
      --replace-fail "appstream_glib = dependency('appstream-glib', version: '>=0.7.10')" ""

    chmod +x desktop/geary-attach
  '';

  strictDeps = true;

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    gobject-introspection
    itstool
    libxml2 # for xmllint for xml-stripblanks preprocessing
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    adwaita-icon-theme
    enchant
    folks
    gcr
    glib-networking
    gmime3
    gnome-online-accounts
    gsettings-desktop-schemas
    gsound
    gspell
    gtk3
    isocodes
    icu
    json-glib
    libgee
    libhandy
    libpeas
    libsecret
    libunwind
    libstemmer
    libxml2
    libytnef
    sqlite
    webkitgtk_4_1
  ];

  mesonFlags = [
    "-Dprofile=release"
    "-Dcontractor=enabled" # install the contractor file (Pantheon specific)
  ];

  # Some tests time out.
  doCheck = false;

  nativeCheckInputs = [
    dbus
    gnutls # for certtool
    cacert # trust store for glib-networking
    xvfb-run
    glibcLocales # required by Geary.ImapDb.DatabaseTest/utf8_case_insensitive_collation
  ];

  checkPhase = ''
    runHook preCheck

    NO_AT_BRIDGE=1 \
    GIO_EXTRA_MODULES=$GIO_EXTRA_MODULES:${glib-networking}/lib/gio/modules \
    HOME=$TMPDIR \
    XDG_DATA_DIRS=$XDG_DATA_DIRS:${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${shared-mime-info}/share:${folks}/share/gsettings-schemas/${folks.name} \
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      meson test -v --no-stdsplit

    runHook postCheck
  '';

  preFixup = ''
    # Add geary to path for geary-attach
    gappsWrapperArgs+=(--prefix PATH : "$out/bin")
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "geary";
    };
  };

  meta = {
    description = "Mail client for GNOME 3";
    homepage = "https://gitlab.gnome.org/GNOME/geary";
    changelog = "https://gitlab.gnome.org/GNOME/geary/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

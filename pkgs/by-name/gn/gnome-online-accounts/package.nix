{
  lib,
  stdenv,
  fetchurl,
  dbus,
  docbook-xsl-nons,
  gcr_4,
  gettext,
  gi-docgen,
  glib,
  glib-networking,
  gnome,
  gobject-introspection,
  gtk4,
  gvfs,
  json-glib,
  keyutils,
  libadwaita,
  libkrb5,
  librest,
  libsecret,
  libsoup_3,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
  enableBackend ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-online-accounts";
  version = "3.58.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-online-accounts/${lib.versions.majorMinor finalAttrs.version}/gnome-online-accounts-${finalAttrs.version}.tar.xz";
    hash = "sha256-nsGQDMUUCcIGfAfIKMEL4G/jv2jSmZu3LX1e0yXtm7w=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals enableBackend [
    "man"
    "devdoc"
  ];

  nativeBuildInputs = [
    docbook-xsl-nons # for goa-daemon.xml
    gettext
    gi-docgen
    gobject-introspection
    libxslt
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    gcr_4
    glib
    glib-networking
    gtk4
    libadwaita
    gvfs # OwnCloud, Google Drive
    json-glib
    libkrb5
    librest
    libxml2
    libsecret
    libsoup_3
  ]
  ++ lib.optionals enableBackend [
    keyutils
  ];

  mesonFlags = [
    "-Dfedora=false" # not useful in NixOS or for NixOS users.
    "-Dgoabackend=${lib.boolToString enableBackend}"
    "-Ddocumentation=${lib.boolToString enableBackend}"
    "-Dman=${lib.boolToString enableBackend}"
    "-Dwebdav=true"
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  separateDebugInfo = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-online-accounts";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Single sign-on framework for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-online-accounts";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})

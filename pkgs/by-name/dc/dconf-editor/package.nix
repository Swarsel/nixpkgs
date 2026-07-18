{
  lib,
  stdenv,
  fetchurl,
  dconf,
  desktop-file-utils,
  docbook-xsl-nons,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk3,
  libhandy,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dconf-editor";
  version = "49.0";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf-editor/${lib.versions.major finalAttrs.version}/dconf-editor-${finalAttrs.version}.tar.xz";
    hash = "sha256-kKjM+t9R3/MeACgyT7mjWLLSbFroYaccfb+fTdm905k=";
  };

  patches = [
    # Look for compiled schemas in NIX_GSETTINGS_OVERRIDES_DIR
    # environment variable, to match what we patched GLib to do.
    ./schema-override-variable.patch
  ];

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    vala
    libxslt
    pkg-config
    wrapGAppsHook3
    gettext
    docbook-xsl-nons
    libxml2
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3
    libhandy
    dconf
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "dconf-editor";
    };
  };

  meta = {
    description = "GSettings editor for GNOME";
    homepage = "https://apps.gnome.org/DconfEditor/";
    changelog = "https://gitlab.gnome.org/GNOME/dconf-editor/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "dconf-editor";
    teams = [ lib.teams.gnome ];
  };
})

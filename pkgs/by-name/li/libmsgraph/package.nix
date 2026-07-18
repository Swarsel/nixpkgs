{
  lib,
  stdenv,
  fetchurl,
  gi-docgen,
  glib,
  gnome,
  gnome-online-accounts,
  gobject-introspection,
  json-glib,
  libsoup_3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  uhttpmock,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmsgraph";
  version = "0.3.4";

  src = fetchurl {
    url = "mirror://gnome/sources/msgraph/${lib.versions.majorMinor finalAttrs.version}/msgraph-${finalAttrs.version}.tar.xz";
    hash = "sha256-BzHs5rArMu7/u72Y79x3vAPd0gZR7q46Q0Pwh5sE1sc=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    gi-docgen
    gobject-introspection
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    uhttpmock
    libxml2
  ];

  propagatedBuildInputs = [
    glib
    gnome-online-accounts
    json-glib
    libsoup_3
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc/msgraph-1" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "libmsgraph";
      packageName = "msgraph";
    };
  };

  meta = {
    description = "Library to access MS Graph API for Office 365";
    homepage = "https://gitlab.gnome.org/GNOME/msgraph";
    changelog = "https://gitlab.gnome.org/GNOME/msgraph/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

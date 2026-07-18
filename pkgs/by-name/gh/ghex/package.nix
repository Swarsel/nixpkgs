{
  lib,
  stdenv,
  fetchurl,
  atk,
  desktop-file-utils,
  gettext,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gtk4,
  itstool,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ghex";
  version = "50.2";

  src = fetchurl {
    url = "mirror://gnome/sources/ghex/${lib.versions.major finalAttrs.version}/ghex-${finalAttrs.version}.tar.xz";
    hash = "sha256-QTTSMYsqqtx6s90z4H1+bb8xZjzvW/0tIbqQ3tX1hKs=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    itstool
    meson
    ninja
    pkg-config
    gi-docgen
    gobject-introspection
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    atk
    glib
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dvapi=true"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # mremap does not exist on darwin
    "-Dmmap-buffer-backend=false"
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "ghex";
    };
  };

  meta = {
    description = "Hex editor for GNOME desktop environment";
    homepage = "https://gitlab.gnome.org/GNOME/ghex";
    changelog = "https://gitlab.gnome.org/GNOME/ghex/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "ghex";
    teams = [ lib.teams.gnome ];
  };
})

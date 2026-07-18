{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  docbook-xsl-nons,
  gitUpdater,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gspell,
  gtk-doc,
  gtk-mac-integration,
  gtk3,
  itstool,
  libgedit-amtk,
  libgedit-gtksourceview,
  libgedit-tepl,
  libpeas,
  libxml2,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gedit";
  version = "50.0";

  src = fetchFromGitLab {
    owner = "gedit";
    repo = "gedit";
    tag = finalAttrs.version;
    hash = "sha256-UkKd1H7twf9r9Jf5Cx6br/8lVT2F2O9U5jR2Ihom0ZA=";
    fetchSubmodules = true;
    domain = "gitlab.gnome.org";
    group = "World";
  };

  outputs = [
    "out"
    "devdoc"
  ];

  patches = [
    # We patch gobject-introspection and meson to store absolute paths to libraries in typelibs
    # but that requires the install_dir is an absolute path.
    ./correct-gir-lib-path.patch
  ];

  nativeBuildInputs = [
    desktop-file-utils
    itstool
    libxml2
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
    gtk-doc
    gobject-introspection
    docbook-xsl-nons
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    gspell
    gtk3
    libgedit-amtk
    libgedit-gtksourceview
    libgedit-tepl
    libpeas
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    gtk-mac-integration
  ];

  # Reliably fails to generate gedit-file-browser-enum-types.h in time
  enableParallelBuilding = false;
  passthru.updateScript = gitUpdater { ignoredVersions = "(alpha|beta|rc).*"; };

  meta = {
    description = "Former GNOME text editor";
    homepage = "https://gitlab.gnome.org/World/gedit/gedit";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bobby285271 ];
    platforms = lib.platforms.unix;
    mainProgram = "gedit";
  };
})

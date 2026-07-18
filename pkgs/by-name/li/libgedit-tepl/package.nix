{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook-xsl-nons,
  gitUpdater,
  gobject-introspection,
  gtk-doc,
  gtk3,
  icu,
  libgedit-amtk,
  libgedit-gfls,
  libgedit-gtksourceview,
  libhandy,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgedit-tepl";
  version = "6.14.0";

  src = fetchFromGitLab {
    owner = "gedit";
    repo = "libgedit-tepl";
    tag = finalAttrs.version;
    hash = "sha256-KtmExJCEfa4c6alrtWOLNSKZUs65tZ7p9zcT9f8ZC+k=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    gobject-introspection
    pkg-config
    gtk-doc
    docbook-xsl-nons
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    icu
    libhandy
  ];

  propagatedBuildInputs = [
    gtk3
    libgedit-amtk
    libgedit-gfls
    libgedit-gtksourceview
  ];

  passthru.updateScript = gitUpdater { ignoredVersions = "(alpha|beta|rc).*"; };

  meta = {
    description = "Text editor product line";
    homepage = "https://gitlab.gnome.org/World/gedit/libgedit-tepl";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      bobby285271
    ];

    platforms = lib.platforms.linux;
  };
})

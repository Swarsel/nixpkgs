{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook-xsl-nons,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk-doc,
  gtk3,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgedit-gfls";
  version = "0.4.2";

  src = fetchFromGitLab {
    owner = "gedit";
    repo = "libgedit-gfls";
    tag = finalAttrs.version;
    hash = "sha256-8nr8rBvSBLadhxHipZiWOJj663R9jP6kFurSKp3n0U0=";
    domain = "gitlab.gnome.org";
    forceFetchGit = true; # To avoid occasional 501 failures.
    group = "World";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    docbook-xsl-nons
    gobject-introspection
    gtk-doc
    meson
    ninja
    pkg-config
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    # Required by libgedit-gfls-1.pc
    glib
  ];

  passthru.updateScript = gitUpdater { ignoredVersions = "(alpha|beta|rc).*"; };

  meta = {
    description = "Module dedicated to file loading and saving";
    homepage = "https://gitlab.gnome.org/World/gedit/libgedit-gfls";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ bobby285271 ];
    platforms = lib.platforms.linux;
  };
})

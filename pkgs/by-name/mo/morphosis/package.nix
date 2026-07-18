{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pandoc,
  pkg-config,
  python3Packages,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "morphosis";
  version = "48.2";

  src = fetchFromGitLab {
    owner = "World";
    repo = "morphosis";
    tag = finalAttrs.version;
    hash = "sha256-wDEhXIt1iup7QxKsmWUjQZGTEZhOuNjpLqzpqs+TPHo=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    desktop-file-utils
    glib # For `glib-compile-schemas`
    gobject-introspection
    gtk4 # For `gtk-update-icon-cache`
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    webkitgtk_6_0
  ];

  dependencies = with python3Packages; [ pygobject3 ];
  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${lib.makeBinPath [ pandoc ]}"
  ];

  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Convert your documents";
    homepage = "https://gitlab.gnome.org/World/morphosis";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ getchoo ];
    platforms = lib.platforms.linux;
    mainProgram = "morphosis";
  };
})

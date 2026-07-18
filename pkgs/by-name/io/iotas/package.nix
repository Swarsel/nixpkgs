{
  lib,
  fetchFromGitLab,
  appstream-glib,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk4,
  gtksourceview5,
  libadwaita,
  librsvg,
  libsecret,
  meson,
  ninja,
  pkg-config,
  python3,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "iotas";
  version = "2026.6";

  src = fetchFromGitLab {
    owner = "World";
    repo = "iotas";
    tag = finalAttrs.version;
    hash = "sha256-Zsfp5O6k8VMjF6Hl3lT+u9JingGq3XgCzc8h9PVAhLg=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    librsvg
    libsecret
    libadwaita
    gtksourceview5
    webkitgtk_6_0
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3.pkgs; [
    pygobject3
    pygtkspellcheck
    requests
    markdown-it-py
    linkify-it-py
    mdit-py-plugins
    pypandoc
    packaging
  ];

  # prevent double wrapping
  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Simple note taking with mobile-first design and Nextcloud sync";
    homepage = "https://gitlab.gnome.org/World/iotas";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "iotas";
    teams = [ lib.teams.gnome-circle ];
  };
})

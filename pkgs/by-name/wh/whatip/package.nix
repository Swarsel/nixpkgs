{
  lib,
  fetchFromGitLab,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "whatip";
  version = "1.2";

  src = fetchFromGitLab {
    owner = "GabMus";
    repo = "whatip";
    rev = finalAttrs.version;
    hash = "sha256-gt/NKgnCpRoVmLvEJJq2geng4miM2g+YhXYEOm5pPTA=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk4
    librsvg
    libadwaita
  ];

  propagatedBuildInputs = with python3.pkgs; [
    netaddr
    requests
    pygobject3
  ];

  pyproject = false;

  meta = {
    description = "Info on your IP";
    homepage = "https://gitlab.gnome.org/GabMus/whatip";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "whatip";
  };
})

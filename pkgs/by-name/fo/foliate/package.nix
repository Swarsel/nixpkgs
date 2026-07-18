{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gettext,
  gjs,
  glib,
  glib-networking,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "foliate";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = "foliate";
    tag = finalAttrs.version;
    hash = "sha256-QpWJDwatT4zOAPF+dn+Sm5xivk9SIZOvexj0M/Nyu24=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gettext
    gjs
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk4
    libadwaita
    webkitgtk_6_0
  ];

  meta = {
    description = "Simple and modern GTK eBook reader";
    homepage = "https://johnfactotum.github.io/foliate";
    changelog = "https://github.com/johnfactotum/foliate/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      onny
      aleksana
    ];

    mainProgram = "foliate";
  };
})

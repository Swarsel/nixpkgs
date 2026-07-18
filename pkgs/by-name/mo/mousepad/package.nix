{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  glib,
  gspell,
  gtk3,
  gtksourceview4,
  libxfce4ui,
  meson,
  ninja,
  pkg-config,
  polkit,
  wrapGAppsHook3,
  xfconf,
  enablePolkit ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mousepad";
  version = "0.7.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "mousepad";
    tag = "mousepad-${finalAttrs.version}";
    hash = "sha256-zoPzMqXfY3ir8MOYXTr+ZNmxISdMgKQEWwIgsVD9oMw=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib # glib-compile-schemas
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gspell
    gtk3
    gtksourceview4
    libxfce4ui # for shortcut plugin
    xfconf # required by libxfce4kbd-private-3
  ]
  ++ lib.optionals enablePolkit [
    polkit
  ];

  # Use the GSettings keyfile backend rather than the default
  mesonFlags = [ "-Dkeyfile-settings=true" ];
  passthru.updateScript = gitUpdater { rev-prefix = "mousepad-"; };

  meta = {
    description = "Simple text editor for Xfce";
    homepage = "https://gitlab.xfce.org/apps/mousepad";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "mousepad";
    teams = [ lib.teams.xfce ];
  };
})

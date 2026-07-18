{
  lib,
  stdenv,
  fetchurl,
  blueprint-compiler,
  desktop-file-utils,
  gdk-pixbuf,
  gnome,
  gtk4,
  libadwaita,
  libmanette,
  librsvg,
  libsndfile,
  meson,
  ninja,
  openal,
  pango,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quadrapassel";
  version = "50.2";

  src = fetchurl {
    url = "mirror://gnome/sources/quadrapassel/${lib.versions.major finalAttrs.version}/quadrapassel-${finalAttrs.version}.tar.xz";
    hash = "sha256-z5mB/WbOy9jsWz5i9SXRTy/OXkd7xdkTqKy+7j/6FH0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    desktop-file-utils
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    pango
    gdk-pixbuf
    librsvg
    libmanette
    # for libgnome-games-support + sound feature
    libsndfile
    openal
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "quadrapassel";
    };
  };

  meta = {
    description = "Classic falling-block game, Tetris";
    homepage = "https://gitlab.gnome.org/GNOME/quadrapassel";
    changelog = "https://gitlab.gnome.org/GNOME/quadrapassel/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "quadrapassel";
    teams = [ lib.teams.gnome ];
  };
})

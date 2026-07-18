{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  desktop-file-utils,
  gtk4,
  gtksourceview5,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  template-glib,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elastic";
  version = "1.0.3";

  src = fetchFromGitLab {
    owner = "World";
    repo = "elastic";
    rev = finalAttrs.version;
    hash = "sha256-NAxztd+Q5TlBAuXCgGPT6aTfj5mVsNdU+5WoNM8Bb84=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    blueprint-compiler
  ];

  buildInputs = [
    gtk4
    libadwaita
    libgee
    gtksourceview5
    template-glib
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Design spring animations";
    homepage = "https://gitlab.gnome.org/World/elastic/";
    changelog = "https://gitlab.gnome.org/World/elastic/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ _0xMRTT ];
    platforms = lib.platforms.unix;
    mainProgram = "app.drey.Elastic";
    teams = [ lib.teams.gnome-circle ];
  };
})

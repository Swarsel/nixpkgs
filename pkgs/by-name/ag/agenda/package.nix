{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gettext,
  glib,
  gtk3,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agenda";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "dahenson";
    repo = "agenda";
    tag = finalAttrs.version;
    hash = "sha256-CjlGkG43FFDdKGuwevBeCCazOzLcH114bqihMWTykC8=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    glib # for glib-compile-schemas
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libgee
    pantheon.granite
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple, fast, no-nonsense to-do (task) list designed for elementary OS";
    homepage = "https://github.com/dahenson/agenda";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xiorcale ];
    platforms = lib.platforms.linux;
    mainProgram = "com.github.dahenson.agenda";
    teams = [ lib.teams.pantheon ];
  };
})

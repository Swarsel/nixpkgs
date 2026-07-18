{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "khronos";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "lainsce";
    repo = "khronos";
    rev = finalAttrs.version;
    sha256 = "sha256-2mO2ZMDxZ7sx2EVTN0tsAv8MisGxlK/1h61N+hOqyGI=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    json-glib
    libadwaita
    libgee
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Track each task's time in a simple inobtrusive way";
    homepage = "https://github.com/lainsce/khronos";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xiorcale ];
    platforms = lib.platforms.linux;
    mainProgram = "io.github.lainsce.Khronos";
    teams = [ lib.teams.pantheon ];
  };
})

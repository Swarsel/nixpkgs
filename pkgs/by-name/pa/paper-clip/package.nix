{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  exempi,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  poppler,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "paper-clip";
  version = "5.5.2";

  src = fetchFromGitHub {
    owner = "Diego-Ivan";
    repo = "Paper-Clip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zJqN66WYYHLZCb6jnREnvhVonbQSucD7VG+JvpbmNMU=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    exempi
    glib
    gtk4
    libadwaita
    poppler
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Edit PDF document metadata";
    homepage = "https://github.com/Diego-Ivan/Paper-Clip";
    changelog = "https://github.com/Diego-Ivan/Paper-Clip/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "pdf-metadata-editor";
    teams = [ lib.teams.gnome-circle ];
  };
})

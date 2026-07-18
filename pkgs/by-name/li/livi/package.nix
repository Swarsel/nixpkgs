{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  desktop-file-utils,
  gst_all_1,
  gtk4,
  libGL,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "livi";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "guidog";
    repo = "livi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2hDQS5f+KAWal8AbtB4IV4/B6Rq+n1vAcWA9eoDS3y4=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gtk4
    libadwaita
    libGL
  ];

  meta = {
    description = "Small video player targeting mobile devices (also named μPlayer)";
    homepage = "https://gitlab.gnome.org/guidog/livi";
    changelog = "https://gitlab.gnome.org/guidog/livi/-/blob/v${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
    mainProgram = "livi";
  };
})

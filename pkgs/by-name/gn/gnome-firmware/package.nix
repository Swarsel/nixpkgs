{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  desktop-file-utils,
  fwupd,
  gettext,
  gitUpdater,
  glib,
  gtk4,
  help2man,
  libadwaita,
  libxmlb,
  meson,
  ninja,
  pkg-config,
  systemd,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-firmware";
  version = "49.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "gnome-firmware";
    rev = finalAttrs.version;
    sha256 = "sha256-3uU0N40O1eoK5JHWMwacSrBzOTq/c+qYwoH9kBOsqrM=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    appstream-glib # for ITS rules
    desktop-file-utils
    gettext
    help2man
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    fwupd
    glib
    gtk4
    libadwaita
    libxmlb
    systemd
  ];

  mesonFlags = [
    "-Dconsolekit=false"
  ];

  passthru.updateScript = gitUpdater {
    ignoredVersions = "(alpha|beta|rc).*";
  };

  meta = {
    description = "Tool for installing firmware on devices";
    homepage = "https://gitlab.gnome.org/World/gnome-firmware";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-firmware";
    teams = [ lib.teams.gnome ];
  };
})

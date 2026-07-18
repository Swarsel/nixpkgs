{
  lib,
  stdenv,
  fetchFromGitLab,
  adwaita-icon-theme,
  evolution-data-server-gtk4,
  gettext,
  gitUpdater,
  glib,
  gnome-online-accounts,
  gsettings-desktop-schemas,
  gtk4,
  itstool,
  libadwaita,
  libical,
  libpeas,
  meson,
  ninja,
  pkg-config,
  wayland,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "endeavour";
  version = "43.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Endeavour";
    rev = finalAttrs.version;
    sha256 = "sha256-1mCTw+nJ1w7RdCXfPCO31t1aYOq9Bki3EaXsHiiveD0=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    # Switch to girepository-2.0
    # libpeas1 will be dropped in https://gitlab.gnome.org/World/Endeavour/-/merge_requests/153
    substituteInPlace src/gui/gtd-application.c \
      --replace-fail "#include <girepository.h>" "#include <girepository/girepository.h>" \
      --replace-fail "g_irepository_get_option_group" "gi_repository_get_option_group"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    wrapGAppsHook4
    itstool
  ];

  buildInputs = [
    glib
    gtk4
    wayland # required by gtk header
    libadwaita
    libpeas
    gnome-online-accounts
    gsettings-desktop-schemas
    adwaita-icon-theme

    # Plug-ins
    evolution-data-server-gtk4 # eds
    libical
  ];

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Personal task manager for GNOME";
    homepage = "https://gitlab.gnome.org/World/Endeavour";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "endeavour";
    teams = [ lib.teams.gnome ];
  };
})

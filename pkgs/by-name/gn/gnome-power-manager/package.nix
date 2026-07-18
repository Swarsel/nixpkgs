{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk4,
  meson,
  ninja,
  pkg-config,
  python3,
  upower,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-power-manager";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-power-manager/${lib.versions.major finalAttrs.version}/gnome-power-manager-${finalAttrs.version}.tar.xz";
    hash = "sha256-vyQ9Y4n4v6cclYU07SZpspllxH9Vw8vkmDspbQ+Z5dc=";
  };

  postPatch = ''
    substituteInPlace meson_post_install.sh \
      --replace-fail "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gettext

    # needed by meson_post_install.sh
    python3
    glib
    desktop-file-utils
  ];

  buildInputs = [
    gtk4
    glib
    upower
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-power-manager"; };
  };

  meta = {
    description = "View battery and power statistics provided by UPower";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-power-manager";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-power-statistics";
    teams = [ lib.teams.gnome ];
  };
})

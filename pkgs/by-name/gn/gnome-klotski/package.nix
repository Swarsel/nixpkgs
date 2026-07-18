{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  appstream-glib,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk3,
  itstool,
  libgee,
  libgnome-games-support,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-klotski";
  version = "3.38.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-klotski/${lib.versions.majorMinor finalAttrs.version}/gnome-klotski-${finalAttrs.version}.tar.xz";
    hash = "sha256-kWN4RWSfPKcJ0p9x7ndblG0REghyCfMiZOj60hoMoOI=";
  };

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  nativeBuildInputs = [
    pkg-config
    vala
    meson
    ninja
    python3
    wrapGAppsHook3
    gettext
    itstool
    libxml2
    appstream-glib
    desktop-file-utils
    adwaita-icon-theme
  ];

  buildInputs = [
    glib
    gtk3
    librsvg
    libgee
    libgnome-games-support
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-klotski"; };
  };

  meta = {
    description = "Slide blocks to solve the puzzle";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-klotski";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-klotski/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-klotski";
    teams = [ lib.teams.gnome ];
  };
})

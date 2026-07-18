{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  gettext,
  gnome,
  gsound,
  gtk3,
  itstool,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "four-in-a-row";
  version = "3.38.1";

  src = fetchurl {
    url = "mirror://gnome/sources/four-in-a-row/${lib.versions.majorMinor finalAttrs.version}/four-in-a-row-${finalAttrs.version}.tar.xz";
    hash = "sha256-IdJ2m4BBFNHPDzN0Jv2IGB7O/WCSz1YmN+s31xYwUYI=";
  };

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    gettext
    meson
    itstool
    vala
    ninja
    python3
    desktop-file-utils
  ];

  buildInputs = [
    gtk3
    gsound
    librsvg
    adwaita-icon-theme
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "four-in-a-row"; };
  };

  meta = {
    description = "Make lines of the same color to win";
    homepage = "https://gitlab.gnome.org/GNOME/four-in-a-row";
    changelog = "https://gitlab.gnome.org/GNOME/four-in-a-row/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "four-in-a-row";
    teams = [ lib.teams.gnome ];
  };
})

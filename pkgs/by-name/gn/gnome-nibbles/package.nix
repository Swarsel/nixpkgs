{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  gnome,
  gsound,
  gtk4,
  itstool,
  libadwaita,
  libgee,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-nibbles";
  version = "4.5.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-nibbles/${lib.versions.majorMinor finalAttrs.version}/gnome-nibbles-${finalAttrs.version}.tar.xz";
    hash = "sha256-dnKdO1Ys14Yq0wWQw71A/SUfnUu1xTuqhBUBl/Ixpfo=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook4
    gettext
    itstool
    libxml2
    desktop-file-utils
  ];

  buildInputs = [
    gsound
    gtk4
    librsvg
    libadwaita
    libgee
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-nibbles"; };
  };

  meta = {
    description = "Guide a worm around a maze";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-nibbles";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-nibbles/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-nibbles";
    teams = [ lib.teams.gnome ];
  };
})

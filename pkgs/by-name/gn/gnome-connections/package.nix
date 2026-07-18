{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk-frdp,
  gtk-vnc,
  gtk3,
  itstool,
  libhandy,
  libsecret,
  libxml2,
  meson,
  ninja,
  pkg-config,
  spice-gtk,
  spice-protocol,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-connections";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-connections/${lib.versions.major finalAttrs.version}/gnome-connections-${finalAttrs.version}.tar.xz";
    hash = "sha256-Vnv2NcbTA66Ex083yE35+4/Pal6d/0UuFBTGcXRNldA=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gettext
    itstool
    desktop-file-utils
    glib # glib-compile-resources
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk-vnc
    gtk3
    libhandy
    libsecret
    libxml2
    gtk-frdp
    spice-gtk
    spice-protocol
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-connections";
    };
  };

  meta = {
    description = "Remote desktop client for the GNOME desktop environment";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-connections";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-connections/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-connections";
    teams = [ lib.teams.gnome ];
  };
})

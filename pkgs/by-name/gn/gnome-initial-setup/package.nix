{
  lib,
  stdenv,
  fetchurl,
  accountsservice,
  dconf,
  fontconfig,
  gdm,
  geoclue2,
  geocode-glib_2,
  gettext,
  glib,
  gnome,
  gnome-desktop,
  gnome-tecla,
  gsettings-desktop-schemas,
  gtk4,
  json-glib,
  krb5,
  libadwaita,
  libgweather,
  libnma-gtk4,
  libpwquality,
  libsecret,
  meson,
  networkmanager,
  ninja,
  pango,
  pkg-config,
  polkit,
  replaceVars,
  systemd,
  tzdata,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-initial-setup";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-initial-setup/${lib.versions.major finalAttrs.version}/gnome-initial-setup-${finalAttrs.version}.tar.xz";
    hash = "sha256-LalrdqNDRGilV/5IG4z+YGJi81N7AKTCDUqiOaROluE=";
  };

  patches = [
    (replaceVars ./0001-fix-paths.patch {
      inherit tzdata;
      tecla = gnome-tecla;
    })
  ];

  nativeBuildInputs = [
    dconf
    gettext
    meson
    ninja
    pkg-config
    systemd
    wrapGAppsHook4
  ];

  buildInputs = [
    accountsservice
    fontconfig
    gdm
    geoclue2
    geocode-glib_2
    glib
    gnome-desktop
    gsettings-desktop-schemas
    gtk4
    json-glib
    krb5
    libgweather
    libadwaita
    libnma-gtk4
    libpwquality
    libsecret
    networkmanager
    pango
    polkit
    webkitgtk_6_0
  ];

  mesonFlags = [
    "-Dibus=disabled"
    "-Dparental_controls=disabled"
    "-Dvendor-conf-file=${./vendor.conf}"
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-initial-setup"; };
  };

  meta = {
    description = "Simple, easy, and safe way to prepare a new system";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-initial-setup";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-initial-setup/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

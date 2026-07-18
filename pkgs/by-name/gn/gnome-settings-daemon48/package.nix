{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  buildPackages,
  colord,
  docbook_xsl,
  gcr_4,
  geoclue2,
  geocode-glib_2,
  gettext,
  glib,
  gnome-desktop,
  gnome-session-ctl,
  gsettings-desktop-schemas,
  gtk3,
  libcanberra-gtk3,
  libgnomekbd,
  libgudev,
  libgweather,
  libnotify,
  libpulseaudio,
  libwacom,
  libxml2,
  libxslt,
  meson,
  modemmanager,
  networkmanager,
  ninja,
  perl,
  pkg-config,
  polkit,
  python3,
  replaceVars,
  systemd,
  tzdata,
  udevCheckHook,
  upower,
  wrapGAppsHook3,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-settings-daemon";
  version = "48.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-settings-daemon/${lib.versions.major finalAttrs.version}/gnome-settings-daemon-${finalAttrs.version}.tar.xz";
    hash = "sha256-OGCi6iFNy8tmAK56HjNYpTiSFQh7w+SkfO4/h7ruBi4=";
  };

  patches = [
    # https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/merge_requests/202
    ./add-gnome-session-ctl-option.patch

    (replaceVars ./fix-paths.patch {
      inherit tzdata;
    })
  ];

  postPatch = ''
    for f in plugins/power/gsd-power-constants-update.pl; do
      chmod +x $f
      patchShebangs $f
    done
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    perl
    gettext
    glib
    libxml2
    libxslt
    docbook_xsl
    wrapGAppsHook3
    python3
    udevCheckHook
  ];

  buildInputs = [
    gtk3
    glib
    gsettings-desktop-schemas
    modemmanager
    networkmanager
    libnotify
    libgnomekbd # for org.gnome.libgnomekbd.keyboard schema
    gnome-desktop
    libpulseaudio
    alsa-lib
    libcanberra-gtk3
    upower
    colord
    libgweather
    polkit
    geocode-glib_2
    geoclue2
    libgudev
    libwacom
    gcr_4
  ]
  ++ lib.optionals withSystemd [
    systemd
  ];

  mesonFlags = [
    "-Dudev_dir=${placeholder "out"}/lib/udev"
    (lib.mesonBool "systemd" withSystemd)
  ]
  ++ lib.optionals withSystemd [
    "-Dgnome_session_ctl_path=${gnome-session-ctl}/libexec/gnome-session-ctl"
  ];

  # Default for release buildtype but passed manually because
  # we're using plain
  env.NIX_CFLAGS_COMPILE = "-DG_DISABLE_CAST_CHECKS";
  doInstallCheck = true;

  depsBuildBuild = [
    buildPackages.stdenv.cc
    pkg-config
  ];

  meta = {
    description = "GNOME Settings Daemon";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-settings-daemon/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
})

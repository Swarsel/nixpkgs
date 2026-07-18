{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  bash,
  catch2_3,
  gdk-pixbuf,
  gettext,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gtk4,
  gtkmm4,
  itstool,
  libadwaita,
  libgtop,
  librsvg,
  meson,
  ninja,
  pkg-config,
  systemd,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-system-monitor";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-system-monitor/${lib.versions.major finalAttrs.version}/gnome-system-monitor-${finalAttrs.version}.tar.xz";
    hash = "sha256-pBOKp1S0WExG3pH60daF4nsSvCRX3nYYY7a+AthMSGI=";
  };

  patches = [
    # Fix pkexec detection on NixOS.
    ./fix-paths.patch
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    itstool
    wrapGAppsHook4
    meson
    ninja
    glib
  ];

  buildInputs = [
    bash
    catch2_3
    gtk4
    libadwaita
    glib
    gtkmm4
    libgtop
    gdk-pixbuf
    adwaita-icon-theme
    librsvg
    gsettings-desktop-schemas
    systemd
  ];

  mesonFlags = [
    # <artificial>:(.text.startup+0x56): undefined reference to `GsmApplication::get()'
    "-Db_lto=false"
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-system-monitor";
    };
  };

  meta = {
    description = "System Monitor shows you what programs are running and how much processor time, memory, and disk space are being used";
    homepage = "https://apps.gnome.org/SystemMonitor/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-system-monitor";
    teams = [ lib.teams.gnome ];
  };
})

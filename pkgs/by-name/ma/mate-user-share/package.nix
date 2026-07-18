{
  lib,
  stdenv,
  fetchurl,
  apacheHttpdPackages,
  caja,
  dbus-glib,
  gettext,
  gitUpdater,
  gtk3,
  hicolor-icon-theme,
  itstool,
  libcanberra-gtk3,
  libnotify,
  libxml2,
  pkg-config,
  wrapGAppsHook3,
}:

let
  inherit (apacheHttpdPackages) apacheHttpd mod_dnssd;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mate-user-share";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-user-share-${finalAttrs.version}.tar.xz";
    sha256 = "iYVgmZkXllE0jkl+8I81C4YIG5expKcwQHfurlc5rjg=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    itstool
    libxml2
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    caja
    dbus-glib
    libnotify
    libcanberra-gtk3
    hicolor-icon-theme
    # Should mod_dnssd and apacheHttpd be runtime dependencies?
    # In gnome-user-share they are not.
    #mod_dnssd
    #apacheHttpd
  ];

  configureFlags = [
    "--with-httpd=${apacheHttpd.out}/bin/httpd"
    "--with-modules-path=${apacheHttpd}/modules"
    "--with-cajadir=$(out)/lib/caja/extensions-2.0"
  ];

  preConfigure = ''
    sed -e 's,^LoadModule dnssd_module.\+,LoadModule dnssd_module ${mod_dnssd}/modules/mod_dnssd.so,' \
      -e 's,''${HTTP_MODULES_PATH},${apacheHttpd}/modules,' \
      -i data/dav_user_2.4.conf
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-user-share";
  };

  meta = {
    description = "User level public file sharing for the MATE desktop";
    homepage = "https://github.com/mate-desktop/mate-user-share";
    license = with lib.licenses; [ gpl2Plus ];
    platforms = lib.platforms.unix;
    mainProgram = "mate-file-share-properties";
    teams = [ lib.teams.mate ];
  };
})

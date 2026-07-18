{
  lib,
  stdenv,
  autoreconfHook,
  dbus-glib,
  fetchbzr,
  glib,
  gtk3,
  json-glib,
  libappindicator-gtk3,
  libdbusmenu-gtk3,
  libindicator-gtk3,
  pkg-config,
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "indicator-application";
  version = "12.10.1";

  src = fetchbzr {
    url = "https://code.launchpad.net/~indicator-applet-developers/${pname}/trunk.17.04";
    rev = "260";
    sha256 = "1f0jdyqqb5g86zdpbcyn16x94yjigsfiv2kf73dvni5rp1vafbq1";
  };

  postPatch = ''
    substituteInPlace data/Makefile.am \
      --replace "/etc/xdg/autostart" "$out/etc/xdg/autostart"
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    dbus-glib # dbus-binding-tool
  ];

  buildInputs = [
    glib
    dbus-glib
    json-glib
    systemd
    gtk3
    libindicator-gtk3
    libdbusmenu-gtk3
    libappindicator-gtk3
  ];

  configureFlags = [
    "CFLAGS=-Wno-error"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  env = {
    PKG_CONFIG_INDICATOR3_0_4_INDICATORDIR = "$(out)/lib/indicators3/7/";
    PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "$(out)/lib/systemd/user";
  };

  # Upstart is not used in NixOS
  postFixup = ''
    rm -rf $out/share/indicator-application/upstart
    rm -rf $out/share/upstart
  '';

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
  ];

  name = "${pname}-gtk3-${version}";

  meta = {
    description = "Indicator to take menus from applications and place them in the panel";
    homepage = "https://launchpad.net/indicator-application";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.msteen ];
    platforms = lib.platforms.linux;
  };
}

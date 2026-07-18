{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  file,
  gettext,
  glib,
  gnome,
  gtk3,
  gtk4,
  libnma,
  libnma-gtk4,
  libsecret,
  networkmanager,
  pkg-config,
  ppp,
  sstp,
  withGnome ? true,
}:

stdenv.mkDerivation rec {
  pname = "NetworkManager-sstp";
  version = "1.3.2";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "sha256-zd+g86cZLyibLhYLal6XzUb9wFu7kHROp0KzRM95Qng=";
  };

  postPatch = ''
    sed -i 's#/sbin/pppd#${ppp}/bin/pppd#' src/nm-sstp-service.c
    sed -i 's#/sbin/sstpc#${sstp}/bin/sstpc#' src/nm-sstp-service.c
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    file
    gettext
    glib # for gdbus-codegen
    pkg-config
  ]
  ++ lib.optionals withGnome [
    gtk4 # for gtk4-builder-tool
  ];

  buildInputs = [
    sstp
    networkmanager
    ppp
  ]
  ++ lib.optionals withGnome [
    gtk3
    gtk4
    libsecret
    libnma
    libnma-gtk4
  ];

  configureFlags = [
    "--with-gnome=${lib.boolToYesNo withGnome}"
    "--with-gtk4=${lib.boolToYesNo withGnome}"
    "--with-pppd-plugin-dir=$(out)/lib/pppd/2.5.0"
    "--enable-absolute-paths"
  ];

  name = "${pname}${lib.optionalString withGnome "-gnome"}-${version}";

  passthru = {
    networkManagerPlugin = "VPN/nm-sstp-service.name";

    updateScript = gnome.updateScript {
      attrPath = "networkmanager-sstp";
      packageName = pname;
    };
  };

  meta = {
    inherit (networkmanager.meta) maintainers teams platforms;
    description = "NetworkManager's sstp plugin";
    license = lib.licenses.gpl2Plus;
  };
}

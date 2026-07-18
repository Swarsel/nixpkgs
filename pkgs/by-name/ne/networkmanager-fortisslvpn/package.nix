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
  openfortivpn,
  pkg-config,
  ppp,
  replaceVars,
  withGnome ? true,
}:

stdenv.mkDerivation rec {
  pname = "NetworkManager-fortisslvpn";
  version = "1.4.0";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "sFXiY0m1FrI1hXmKs+9XtDawFIAOkqiscyz8jnbF2vo=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit openfortivpn;
    })
    ./support-ppp-2.5.0.patch
    ./pppd-accept-remote.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    gettext
    pkg-config
    file
    glib
  ];

  buildInputs = [
    openfortivpn
    networkmanager
    ppp
    glib
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
    "--localstatedir=/var"
    "--enable-absolute-paths"
  ];

  installFlags = [
    # the installer only creates an empty directory in localstatedir, so
    # we can drop it
    "localstatedir=."
  ];

  name = "${pname}${lib.optionalString withGnome "-gnome"}-${version}";

  passthru = {
    networkManagerPlugin = "VPN/nm-fortisslvpn-service.name";

    networkManagerTmpfilesRules = [
      "d /var/lib/NetworkManager-fortisslvpn 0700 root root -"
    ];

    updateScript = gnome.updateScript {
      attrPath = "networkmanager-fortisslvpn";
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    inherit (networkmanager.meta) maintainers teams platforms;
    description = "NetworkManager’s FortiSSL plugin";
    license = lib.licenses.gpl2Plus;
  };
}

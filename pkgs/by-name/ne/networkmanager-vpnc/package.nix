{
  lib,
  stdenv,
  fetchurl,
  file,
  glib,
  gnome,
  gtk3,
  gtk4,
  kmod,
  libnma,
  libnma-gtk4,
  libsecret,
  networkmanager,
  pkg-config,
  replaceVars,
  vpnc,
  withGnome ? true,
}:

stdenv.mkDerivation rec {
  pname = "NetworkManager-vpnc";
  version = "1.4.0";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-vpnc/${lib.versions.majorMinor version}/NetworkManager-vpnc-${version}.tar.xz";
    sha256 = "47KpiIAnWht1FUvDF6eGQ8/fnqfnDfTu2WSPKeolNzA=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit vpnc kmod;
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    file
    glib
  ];

  buildInputs = [
    vpnc
    networkmanager
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
    "--enable-absolute-paths"
  ];

  passthru = {
    networkManagerPlugin = "VPN/nm-vpnc-service.name";

    updateScript = gnome.updateScript {
      attrPath = "networkmanager-vpnc";
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    inherit (networkmanager.meta) maintainers teams platforms;
    description = "NetworkManager's VPNC plugin";
    license = lib.licenses.gpl2Plus;
  };
}

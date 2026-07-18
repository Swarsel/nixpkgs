{
  lib,
  stdenv,
  fetchurl,
  file,
  gcr,
  glib,
  gnome,
  gtk3,
  gtk4,
  intltool,
  kmod,
  libnma,
  libnma-gtk4,
  libsecret,
  libxml2,
  networkmanager,
  openconnect,
  pkg-config,
  replaceVars,
  webkitgtk_4_1,
  withGnome ? true,
}:

stdenv.mkDerivation rec {
  pname = "NetworkManager-openconnect";
  version = "1.2.10";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-openconnect/${lib.versions.majorMinor version}/NetworkManager-openconnect-${version}.tar.xz";
    sha256 = "hEtr9k7K25e0pox3bbiapebuflm9JLAYAihAaGMTZGQ=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit kmod openconnect;
    })
  ];

  nativeBuildInputs = [
    glib
    intltool
    pkg-config
    file
  ];

  buildInputs = [
    libxml2
    openconnect
    networkmanager
    webkitgtk_4_1 # required, for SSO
  ]
  ++ lib.optionals withGnome [
    gtk3
    libnma
    libnma-gtk4
    gtk4
    gcr
    libsecret
  ];

  configureFlags = [
    "--with-gnome=${lib.boolToYesNo withGnome}"
    "--with-gtk4=${lib.boolToYesNo withGnome}"
    "--enable-absolute-paths"
  ];

  passthru = {
    networkManagerPlugin = "VPN/nm-openconnect-service.name";
    networkManagerRuntimeDeps = [ openconnect ];

    updateScript = gnome.updateScript {
      attrPath = "networkmanager-openconnect";
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    inherit (networkmanager.meta) maintainers teams platforms;
    description = "NetworkManager’s OpenConnect plugin";
    license = lib.licenses.gpl2Plus;
  };
}

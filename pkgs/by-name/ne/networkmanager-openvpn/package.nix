{
  lib,
  stdenv,
  fetchurl,
  file,
  gettext,
  glib,
  gnome,
  gtk3,
  gtk4,
  kmod,
  libnma,
  libnma-gtk4,
  libsecret,
  libxml2,
  networkmanager,
  openvpn,
  pkg-config,
  replaceVars,
  withGnome ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "NetworkManager-openvpn";
  version = "1.12.3";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-openvpn/${lib.versions.majorMinor finalAttrs.version}/NetworkManager-openvpn-${finalAttrs.version}.tar.xz";
    sha256 = "S9ochVm7jDX28THAntrpDN/M0DFOi4y5isVeCbYAWtw=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit kmod openvpn;
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    glib
    pkg-config
    file
    libxml2
  ];

  buildInputs = [
    openvpn
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
    "--localstatedir=/" # needed for the management socket under /run/NetworkManager
    "--enable-absolute-paths"
  ];

  passthru = {
    networkManagerPlugin = "VPN/nm-openvpn-service.name";

    updateScript = gnome.updateScript {
      attrPath = "networkmanager-openvpn";
      packageName = "NetworkManager-openvpn";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    inherit (networkmanager.meta) maintainers teams platforms;
    description = "NetworkManager's OpenVPN plugin";
    homepage = "https://gitlab.gnome.org/GNOME/NetworkManager-openvpn";
    changelog = "https://gitlab.gnome.org/GNOME/NetworkManager-openvpn/-/blob/main/NEWS";
    license = lib.licenses.gpl2Plus;
  };
})

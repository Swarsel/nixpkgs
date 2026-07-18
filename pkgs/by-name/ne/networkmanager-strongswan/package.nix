{
  lib,
  stdenv,
  fetchurl,
  gtk3,
  gtk4,
  intltool,
  libnma,
  libnma-gtk4,
  libsecret,
  networkmanager,
  pkg-config,
  strongswanNM,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "NetworkManager-strongswan";
  version = "1.6.5";

  src = fetchurl {
    url = "https://download.strongswan.org/NetworkManager/NetworkManager-strongswan-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-OpHK38x8dGFkcLKw+A203BfxAzYrOG7XY0edhQBQG2c=";
  };

  nativeBuildInputs = [
    intltool
    pkg-config
  ];

  buildInputs = [
    networkmanager
    strongswanNM
    libsecret
    gtk3
    gtk4
    libnma
    libnma-gtk4
  ];

  configureFlags = [
    "--disable-more-warnings" # disables -Werror
    "--with-charon=${strongswanNM}/libexec/ipsec/charon-nm"
    "--with-nm-libexecdir=${placeholder "out"}/libexec"
    "--with-nm-plugindir=${placeholder "out"}/lib/NetworkManager"
    "--with-gtk4"
  ];

  env.PKG_CONFIG_LIBNM_VPNSERVICEDIR = "${placeholder "out"}/lib/NetworkManager/VPN";

  passthru = {
    networkManagerDbusDeps = [ strongswanNM ];
    networkManagerPlugin = "VPN/nm-strongswan-service.name";

    networkManagerTmpfilesRules = [
      "d /etc/ipsec.d 0700 root root -"
    ];
  };

  meta = {
    inherit (networkmanager.meta) platforms;
    description = "NetworkManager's strongswan plugin";
    license = lib.licenses.gpl2Plus;
  };
})

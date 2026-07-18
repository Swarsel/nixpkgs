{
  lib,
  stdenv,
  fetchurl,
  libnl,
  nixosTests,
  openssl,
  pkg-config,
  sqlite ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hostapd";
  version = "2.11";

  src = fetchurl {
    url = "https://w1.fi/releases/hostapd-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-Kz+stjL9T2XjL0v4Kna0tyxQH5laT2LjMCGf567RdHo=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (fetchurl {
      sha256 = "08p5frxhpq1rp2nczkscapwwl8g9nc4fazhjpxic5bcbssc3sb00";
      # Note: fetchurl seems to be unhappy with openwrt git
      # server's URLs containing semicolons. Using the github mirror instead.
      url = "https://raw.githubusercontent.com/openwrt/openwrt/eefed841b05c3cd4c65a78b50ce0934d879e6acf/package/network/services/hostapd/patches/300-noscan.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libnl
    openssl
    sqlite
  ];

  preInstall = "mkdir -p $out/bin";

  postInstall = ''
    install -vD hostapd.8 -t $man/share/man/man8
    install -vD hostapd_cli.1 -t $man/share/man/man1
  '';

  __structuredAttrs = true;

  configurePhase = ''
    cd hostapd
    cp -v defconfig .config
    printf "%s" "$extraConfig" >> .config
    cat -n .config
    substituteInPlace Makefile --replace /usr/local $out
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags libnl-3.0)"
  '';

  # Based on hostapd's defconfig. Only differences are tracked.
  extraConfig = ''
    # Use epoll(7) instead of select(2) on linux
    CONFIG_ELOOP_EPOLL=y

    # Drivers
    CONFIG_DRIVER_WIRED=y
    CONFIG_DRIVER_NONE=y

    # Integrated EAP server
    CONFIG_EAP_SIM=y
    CONFIG_EAP_AKA=y
    CONFIG_EAP_AKA_PRIME=y
    CONFIG_EAP_PAX=y
    CONFIG_EAP_PSK=y
    CONFIG_EAP_PWD=y
    CONFIG_EAP_SAKE=y
    CONFIG_EAP_GPSK=y
    CONFIG_EAP_GPSK_SHA256=y
    CONFIG_EAP_FAST=y
    CONFIG_EAP_IKEV2=y
    CONFIG_EAP_TNC=y
    CONFIG_EAP_EKE=y

    CONFIG_TLS=openssl
    CONFIG_TLSV11=y
    CONFIG_TLSV12=y

    CONFIG_SAE=y
    CONFIG_SAE_PK=y

    CONFIG_OWE=y
    CONFIG_OCV=y

    # TKIP is considered insecure and upstream support will be removed in the future
    CONFIG_NO_TKIP=y

    # Misc
    CONFIG_RADIUS_SERVER=y
    CONFIG_MACSEC=y
    CONFIG_DRIVER_MACSEC_LINUX=y
    CONFIG_FULL_DYNAMIC_VLAN=y
    CONFIG_VLAN_NETLINK=y
    CONFIG_GETRANDOM=y
    CONFIG_INTERWORKING=y
    CONFIG_HS20=y
    CONFIG_FST=y
    CONFIG_FST_TEST=y
    CONFIG_ACS=y
    CONFIG_WNM=y
    CONFIG_MBO=y
    CONFIG_WPA_CLI_EDIT=y

    CONFIG_IEEE80211R=y
    CONFIG_IEEE80211W=y
    CONFIG_IEEE80211N=y
    CONFIG_IEEE80211AC=y
    CONFIG_IEEE80211AX=y
    CONFIG_IEEE80211BE=y
  ''
  + lib.optionalString (sqlite != null) ''
    CONFIG_SQLITE=y
  '';

  passthru.tests = {
    inherit (nixosTests) wpa_supplicant;
  };

  meta = {
    description = "User space daemon for access point and authentication servers";
    homepage = "https://w1.fi/hostapd/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ oddlama ];
    platforms = lib.platforms.linux;
    mainProgram = "hostapd";
  };
})

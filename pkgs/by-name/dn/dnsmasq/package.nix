{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  dbus,
  libidn2,
  libnetfilter_conntrack,
  nettle,
  nftables,
  nixosTests,
  pkg-config,
  dbusSupport ? stdenv.hostPlatform.isLinux,
}:

let
  copts = lib.concatStringsSep " " (
    [
      "-DHAVE_LIBIDN2"
      "-DHAVE_DNSSEC"
    ]
    ++ lib.optionals dbusSupport [
      "-DHAVE_DBUS"
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      "-DHAVE_CONNTRACK"
      "-DHAVE_NFTSET"
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dnsmasq";
  version = "2.93";

  src = fetchurl {
    url = "https://www.thekelleys.org.uk/dnsmasq/dnsmasq-${finalAttrs.version}.tar.xz";
    hash = "sha256-DADU5cl8gwbl+5MrNIs0JpycKaDn3w6OgpWLQHCSvBk=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    sed '1i#include <linux/sockios.h>' -i src/dhcp.c
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    nettle
    libidn2
  ]
  ++ lib.optionals dbusSupport [ dbus ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libnetfilter_conntrack
    nftables
  ];

  makeFlags = [
    "DESTDIR="
    "BINDIR=$(out)/bin"
    "MANDIR=$(out)/man"
    "LOCALEDIR=$(out)/share/locale"
    "PKG_CONFIG=${buildPackages.pkg-config}/bin/${buildPackages.pkg-config.targetPrefix}pkg-config"
  ];

  preBuild = ''
    makeFlagsArray=("COPTS=${copts}")
  '';

  postBuild = lib.optionalString stdenv.hostPlatform.isLinux ''
    make -C contrib/lease-tools
  '';

  # XXX: Does the systemd service definition really belong here when our NixOS
  # module can create it in Nix-land?
  postInstall = ''
    install -Dm644 trust-anchors.conf $out/share/dnsmasq/trust-anchors.conf
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install -Dm644 contrib/MacOSX-launchd/uk.org.thekelleys.dnsmasq.plist \
      $out/Library/LaunchDaemons/uk.org.thekelleys.dnsmasq.plist
    substituteInPlace $out/Library/LaunchDaemons/uk.org.thekelleys.dnsmasq.plist \
      --replace "/usr/local/sbin" "$out/bin"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm755 contrib/lease-tools/dhcp_lease_time $out/bin/dhcp_lease_time
    install -Dm755 contrib/lease-tools/dhcp_release $out/bin/dhcp_release
    install -Dm755 contrib/lease-tools/dhcp_release6 $out/bin/dhcp_release6

  ''
  + lib.optionalString dbusSupport ''
    install -Dm644 dbus/dnsmasq.conf $out/share/dbus-1/system.d/dnsmasq.conf
    mkdir -p $out/share/dbus-1/system-services
    cat <<END > $out/share/dbus-1/system-services/uk.org.thekelleys.dnsmasq.service
    [D-BUS Service]
    Name=uk.org.thekelleys.dnsmasq
    Exec=$out/bin/dnsmasq -k -1
    User=root
    SystemdService=dnsmasq.service
    END
  '';

  enableParallelBuilding = true;

  passthru.tests = {
    # these tests use dnsmasq incidentally
    inherit (nixosTests) dnscrypt-proxy;
    kubernetes-dns-multi = nixosTests.kubernetes.dns-multi-node;
    kubernetes-dns-single = nixosTests.kubernetes.dns-single-node;
    pihole-ftl-dnsmasq = nixosTests.pihole-ftl.dnsmasq;
    prometheus-exporter = nixosTests.prometheus-exporters.dnsmasq;
  };

  meta = {
    description = "Integrated DNS, DHCP and TFTP server for small networks";
    homepage = "https://www.thekelleys.org.uk/dnsmasq/doc.html";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      fpletz
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "dnsmasq";
  };
})

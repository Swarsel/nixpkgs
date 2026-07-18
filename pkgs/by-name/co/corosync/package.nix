{
  lib,
  stdenv,
  fetchurl,
  dbus,
  fetchpatch2,
  kronosnet,
  libqb,
  libstatgrab,
  makeWrapper,
  net-snmp,
  nixosTests,
  nspr,
  nss,
  pkg-config,
  rdma-core,
  systemd,
  enableDbus ? false,
  enableInfiniBandRdma ? false,
  enableMonitoring ? false,
  enableSnmp ? false,
}:

let
  inherit (lib) optional;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "corosync";
  version = "3.1.9";

  src = fetchurl {
    url = "https://build.clusterlabs.org/corosync/releases/corosync-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-IDNUu93uGpezxQoHbq6JxjX0Bt1nTMrvyUu5CSrNlTU=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-EgGTfOM9chjLnb1QWNGp6IQQKQGdetNkztdddXlN/uo=";
      name = "CVE-2025-30472.patch";
      url = "https://github.com/corosync/corosync/commit/7839990f9cdf34e55435ed90109e82709032466a.patch??full_index=1";
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    kronosnet
    nss
    nspr
    libqb
    systemd.dev
  ]
  ++ optional enableDbus dbus
  ++ optional enableInfiniBandRdma rdma-core
  ++ optional enableMonitoring libstatgrab
  ++ optional enableSnmp net-snmp;

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-logdir=/var/log/corosync"
    "--enable-watchdog"
    "--enable-qdevices"
    # allows Type=notify in the systemd service
    "--enable-systemd"
  ]
  ++ optional enableDbus "--enable-dbus"
  ++ optional enableInfiniBandRdma "--enable-rdma"
  ++ optional enableMonitoring "--enable-monitoring"
  ++ optional enableSnmp "--enable-snmp";

  preConfigure = lib.optionalString enableInfiniBandRdma ''
    # configure looks for the pkg-config files
    # of librdmacm and libibverbs
    # Howver, rmda-core does not provide a pkg-config file
    # We give the flags manually here:
    export rdmacm_LIBS=-lrdmacm
    export rdmacm_CFLAGS=" "
    export ibverbs_LIBS=-libverbs
    export ibverbs_CFLAGS=" "
  '';

  postInstall = ''
    wrapProgram $out/bin/corosync-blackbox \
      --prefix PATH ":" "$out/sbin:${libqb}/sbin"
  '';

  enableParallelBuilding = true;

  installFlags = [
    "sysconfdir=$(out)/etc"
    "localstatedir=$(out)/var"
    "COROSYSCONFDIR=$(out)/etc/corosync"
    "INITDDIR=$(out)/etc/init.d"
    "LOGROTATEDIR=$(out)/etc/logrotate.d"
  ];

  passthru.tests = {
    inherit (nixosTests) pacemaker;
  };

  meta = {
    description = "Group Communication System with features for implementing high availability within applications";
    homepage = "https://corosync.org/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      montag451
      ryantm
    ];

    platforms = lib.platforms.linux;
  };
})

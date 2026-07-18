{
  lib,
  stdenv,
  fetchurl,
  bash,
  bashNonInteractive,
  bison,
  bluez,
  # for passthru.tests
  ettercap,
  flex,
  haskellPackages,
  libnl,
  libxcrypt,
  nmap,
  ostinato,
  pkg-config,
  python3,
  rdma-core,
  tcpreplay,
  vde2,
  wireshark,
  withBluez ? false,
  withRdma ? false,
  withRemote ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libpcap";
  version = "1.10.6";

  src = fetchurl {
    url = "https://www.tcpdump.org/release/libpcap-${finalAttrs.version}.tar.gz";
    hash = "sha256-hy3REzf+GrAq2dT+4EfJ2iRNaVxt3zTi67cz79Ttiqk=";
  };

  outputs = [
    "out"
    "lib"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    flex
    bison
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];

  buildInputs = [
    bash
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libnl ]
  ++ lib.optionals withRdma [ rdma-core ]
  ++ lib.optionals withRemote [ libxcrypt ]
  ++ lib.optionals withBluez [ bluez ];

  # We need to force the autodetection because detection doesn't
  # work in pure build environments.
  configureFlags = [
    "--with-pcap=${if stdenv.hostPlatform.isLinux then "linux" else "bpf"}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--disable-universal"
  ]
  ++ lib.optionals withRdma [
    "--enable-rdma"
  ]
  ++ lib.optionals withRemote [
    "--enable-remote"
  ]
  ++ lib.optionals (stdenv.hostPlatform == stdenv.buildPlatform) [ "ac_cv_linux_vers=2" ];

  postInstall = ''
    if [ "$dontDisableStatic" -ne "1" ]; then
      rm -f $out/lib/libpcap.a
    fi
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  outputChecks.lib.disallowedRequisites = [
    bash
    bashNonInteractive
  ];

  passthru.tests = {
    inherit
      ettercap
      nmap
      ostinato
      tcpreplay
      vde2
      wireshark
      ;

    inherit (python3.pkgs) pcapy-ng scapy;
    haskell-pcap = haskellPackages.pcap;
  };

  meta = {
    description = "Packet Capture Library";
    homepage = "https://www.tcpdump.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
    mainProgram = "pcap-config";
  };
})

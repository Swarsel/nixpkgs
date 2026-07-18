{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  dpdk,
  elfutils,
  intel-ipsec-mb,
  jansson,
  libbpf,
  libbsd,
  libconfig,
  libnl,
  libpcap,
  nix-update-script,
  numactl,
  openssl,
  pkg-config,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "odp-dpdk";
  version = "1.50.0.0_DPDK_24.11";

  src = fetchFromGitHub {
    owner = "OpenDataPlane";
    repo = "odp-dpdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q1xJ5JCrR/RH5Mxnrs6+gR3D7I2BpmPDki0yJ+5N/UE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    dpdk
    intel-ipsec-mb
    libconfig
    libpcap
    numactl
    openssl
    zlib
    zstd
    libbsd
    elfutils
    jansson
    libbpf
    libnl
  ];

  __structuredAttrs = true;
  # binaries will segfault otherwise
  dontStrip = true;
  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open Data Plane optimized for DPDK";
    homepage = "https://www.opendataplane.org";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      abuibrahim
      stepbrobd
    ];

    platforms = lib.platforms.linux;
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dpdk,
  jansson,
  libbpf,
  libelf,
  libiberty,
  libmnl,
  libnl,
  libpcap,
  libunwind,
  nix-update-script,
  openssl,
  pkg-config,
  python3,
  rdma-core,
  writeText,
  xdp-tools,
  zlib,
  # Support for all network cards, but slower than native XDP
  enableAfXdpSkbMode ? false,
  withAfXdp ? true,
  withDpdk ? true,
  withLibPcap ? true, # bpf_trace_filter plugin
  withNetlinkLibs ? true, # linux-cp plugin
  withOpenssl ? true, # tls/quic/wireguard plugins
  withRdma ? true,
  # optional dependencies
  withStackTraces ? true,
}:
let
  dpdk' = dpdk.overrideAttrs (old: {
    mesonFlags = old.mesonFlags ++ [ "-Denable_driver_sdk=true" ];
  });

  # >=25.02 uses /etc/os-release, so we substitute it
  osRelease = writeText "os-release" "ID=nixos";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vpp";
  version = "26.02";

  src = fetchFromGitHub {
    owner = "FDio";
    repo = "vpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z9yh1ZMP28SSzHNBdO7UnvVqsIqtXUcwYZUH1UdBUB0=";
  };

  patches = [
    # VPP links to static RDMA/XDP by default
    ./use-dynamic-libs.patch
  ]
  ++ lib.optional enableAfXdpSkbMode ./xdp-skb-mode.patch;

  postPatch = ''
    patchShebangs scripts/
    substituteInPlace pkg/CMakeLists.txt \
      --replace-fail "/etc/os-release" "${osRelease}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    (python3.withPackages (ps: [ ps.ply ]))
  ];

  buildInputs =
    lib.optionals withStackTraces [
      libiberty
      libunwind
    ]
    ++ lib.optional withOpenssl openssl
    ++ lib.optional withLibPcap libpcap
    ++ lib.optionals withNetlinkLibs [
      libnl
      libmnl
    ]
    ++ lib.optionals withDpdk [
      dpdk'
      jansson
      libelf
      zlib
    ]
    ++ lib.optional withRdma rdma-core
    ++ lib.optionals withAfXdp [
      libelf
      libbpf
      xdp-tools
      zlib
    ];

  cmakeFlags = [
    "-DVPP_PLATFORM=default"
    "-DVPP_LIBRARY_DIR=lib"
    "-DVPP_BUILD_PYTHON_API=false" # fails to build as of 25.10
  ]
  ++ lib.optional withDpdk "-DVPP_USE_SYSTEM_DPDK=ON";

  preConfigure = ''
    echo "${finalAttrs.version}-nixos" > scripts/.version
    ./scripts/version
  '';

  postConfigure = ''
    patchShebangs ../tools/
    patchShebangs ../vpp-api/
  '';

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/src";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, scalable layer 2-4 multi-platform network stack running in user space";
    homepage = "https://s3-docs.fd.io/vpp/${finalAttrs.version}/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ maevii ];
    platforms = lib.platforms.linux;
    mainProgram = "vpp";
  };
})

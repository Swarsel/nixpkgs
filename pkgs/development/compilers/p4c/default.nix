{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  boehmgc,
  boost,
  cmake,
  doxygen,
  fetchpatch,
  flex,
  gmp,
  graphviz,
  libbpf,
  libllvm,
  protobuf,
  python3,
  enableBMV2 ? true,
  enableBPF ? true,
  enableDPDK ? true,
  enableDocumentation ? true,
  enableGTests ? true,
  enableGraphBackend ? true,
  enableMultithreading ? false,
  enableP4Tests ? true,
}:
let
  toCMakeBoolean = v: if v then "ON" else "OFF";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "p4c";
  version = "1.2.4.1";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "p4c";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Whdryz1Gt0ymE7cj+mI95lW3Io9yBvLqcWa04gu5zEw=";
    fetchSubmodules = true;
  };

  patches = [
    # Fix gcc-13 build:
    #   https://github.com/p4lang/p4c/pull/4084
    (fetchpatch {
      hash = "sha256-wWM1qjgQCNMPdrhQF38jzFgODUsAcaHTajdbV7L3y8o=";
      name = "gcc-13.patch";
      url = "https://github.com/p4lang/p4c/commit/6756816100b7c51e3bf717ec55114a8e8575ba1d.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    bison
    flex
    cmake
    protobuf
    python3
  ]
  ++ lib.optionals enableDocumentation [
    doxygen
    graphviz
  ]
  ++ lib.optionals enableBPF [
    libllvm
    libbpf
  ];

  buildInputs = [
    protobuf
    boost
    boehmgc
    gmp
    flex
  ];

  cmakeFlags = [
    "-DENABLE_BMV2=${toCMakeBoolean enableBMV2}"
    "-DENABLE_EBPF=${toCMakeBoolean enableBPF}"
    "-DENABLE_UBPF=${toCMakeBoolean enableBPF}"
    "-DENABLE_DPDK=${toCMakeBoolean enableDPDK}"
    "-DENABLE_P4C_GRAPHS=${toCMakeBoolean enableGraphBackend}"
    "-DENABLE_P4TEST=${toCMakeBoolean enableP4Tests}"
    "-DENABLE_DOCS=${toCMakeBoolean enableDocumentation}"
    "-DENABLE_GC=ON"
    "-DENABLE_GTESTS=${toCMakeBoolean enableGTests}"
    "-DENABLE_PROTOBUF_STATIC=OFF" # static protobuf has been removed since 3.21.6
    "-DENABLE_MULTITHREAD=${toCMakeBoolean enableMultithreading}"
    "-DENABLE_GMP=ON"
  ];

  checkTarget = "check";

  postFetch = ''
    rm -rf backends/ebpf/runtime/contrib/libbpf
    rm -rf control-plane/p4runtime
  '';

  meta = {
    description = "Reference compiler for the P4 programming language";
    homepage = "https://github.com/p4lang/p4c";
    changelog = "https://github.com/p4lang/p4c/releases";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      raitobezarius
      govanify
    ];

    platforms = lib.platforms.linux;
  };
})

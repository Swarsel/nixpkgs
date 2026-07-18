{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
  cmake,
  elfutils,
  fetchpatch,
  fmt,
  glog,
  libpciaccess,
  libxml2,
  numactl,
  python3Packages,
  rocmUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocprofiler-register";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-systems";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-XhxED3LHIjxBcSVyyEC3pgg0fyKyfKtHkF7umExSboM=";

    sparseCheckout = [
      "projects/rocprofiler-register"
      "shared"
    ];
  };

  patches = [
    (fetchpatch {
      hash = "sha256-dwqvZ4AaTcOk2mSnxgHp/NbhjlD8W6KVz1H5ZF4i/Tw=";
      relative = "projects/rocprofiler-register";
      # [rocprofiler-sdk][rocprofiler-register] add CPackComponent
      url = "https://github.com/ROCm/rocm-systems/commit/ef7253365c420ca486f074b9e9119a222e30fea0.patch";
    })
    (fetchpatch {
      hash = "sha256-VloRKV6kUzIfIInltx/bV1EM0FUfeQZrVAx6qgdsLyg=";
      relative = "projects/rocprofiler-register";
      # [rocprofiler-register] Fix compilation with system fmt/glog
      url = "https://github.com/ROCm/rocm-systems/commit/c8ad2522083c6e00539ce5c1c22df766c20084fb.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    clang
  ];

  buildInputs = [
    numactl
    libpciaccess
    libxml2
    elfutils
    glog
    fmt

    python3Packages.lxml
    python3Packages.cppheaderparser
    python3Packages.pyyaml
    python3Packages.barectf
    python3Packages.pandas
  ];

  cmakeFlags = [
    "-DROCPROFILER_REGISTER_BUILD_TESTS=0"
    "-DROCPROFILER_REGISTER_BUILD_SAMPLES=0"
    "-DROCPROFILER_REGISTER_BUILD_GLOG=OFF"
    "-DROCPROFILER_REGISTER_BUILD_FMT=OFF"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  sourceRoot = "${finalAttrs.src.name}/projects/rocprofiler-register";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Profiling with perf-counters and derived metrics";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/rocprofiler-register";
    license = with lib.licenses; [ mit ]; # mitx11
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})

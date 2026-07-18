{
  lib,
  stdenv,
  fetchFromGitHub,
  amdsmi,
  cmake,
  doxygen,
  graphviz,
  grpc,
  gtest,
  libcap,
  libdrm,
  openssl,
  pkg-config,
  protobuf,
  rocm-runtime,
  rocm-smi,
  rocmUpdateScript,
  texliveSmall,
  buildDocs ? true,
  buildTests ? false,
}:

let
  latex = lib.optionalAttrs buildDocs (
    texliveSmall.withPackages (
      ps: with ps; [
        changepage
        latexmk
        varwidth
        multirow
        hanging
        adjustbox
        collectbox
        stackengine
        enumitem
        alphalph
        wasysym
        sectsty
        tocloft
        newunicodechar
        etoc
        helvetic
        wasy
        courier
      ]
    )
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rdc";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-systems";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-SmySauRxFnEQJVTjGYf4TpmQclTwZG2RZrk3u6ko5Qo=";

    sparseCheckout = [
      "projects/rdc"
      "shared"
    ];
  };

  outputs = [
    "out"
  ]
  ++ lib.optionals buildDocs [
    "doc"
  ]
  ++ lib.optionals buildTests [
    "test"
  ];

  patches = [
    # https://github.com/ROCm/rocm-systems/pull/2423
    ./fix-cmake-cxxflags.patch
    # https://github.com/ROCm/rocm-systems/pull/2424
    ./fix-libcap-pkgconfig.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "file(STRINGS /etc/os-release LINUX_DISTRO LIMIT_COUNT 1 REGEX \"NAME=\")" "set(LINUX_DISTRO \"NixOS\")"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ]
  ++ lib.optionals buildDocs [
    doxygen
    graphviz
    latex
  ];

  buildInputs = [
    amdsmi
    rocm-smi
    rocm-runtime
    libcap
    libdrm
    grpc
    openssl
  ]
  ++ lib.optionals buildTests [
    gtest
  ];

  cmakeFlags = [
    "-DCMAKE_VERBOSE_MAKEFILE=ON"
    "-DRDC_INSTALL_PREFIX=${placeholder "out"}"
    "-DBUILD_RVS=OFF" # TODO: Needs RVS package
    "-DBUILD_ROCRTEST=ON"
    "-DRSMI_INC_DIR=${rocm-smi}/include"
    "-DRSMI_LIB_DIR=${rocm-smi}/lib"
    "-DGRPC_ROOT=${grpc}"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBEXECDIR=libexec"
    "-DCMAKE_INSTALL_DOCDIR=doc"
  ]
  ++ lib.optionals buildTests [
    "-DBUILD_TESTS=ON"
  ];

  postInstall = ''
    find $out/bin -executable -type f -exec \
      patchelf {} --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" \;
  ''
  + lib.optionalString buildTests ''
    mkdir -p $test
    mv $out/bin/rdctst_tests $test/bin
  '';

  sourceRoot = "${finalAttrs.src.name}/projects/rdc";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Simplifies administration and addresses infrastructure challenges in cluster and datacenter environments";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/rdc";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})

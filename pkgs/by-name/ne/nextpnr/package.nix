{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  eigen,
  icestorm,
  llvmPackages,
  python3,
  python3Packages,
  trellis,
  enableGui ? false,
  qtbase ? null,
  wrapQtAppsHook ? null,
}:

let
  boostPython = boost.override {
    enablePython = true;
    python = python3;
  };

  prjbeyond_src = fetchFromGitHub {
    hash = "sha256-B/VmKgMu6f2Y8umE+NgGD5W0FYBIfDcMVwgHocFzreA=";
    owner = "YosysHQ-GmbH";
    repo = "prjbeyond-db";
    rev = "f49f66be674d9857c657930353b867ba94bcbdd7";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "nextpnr";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "nextpnr";
    tag = "nextpnr-${finalAttrs.version}";
    hash = "sha256-goHHEvkBw+9s3RHGfQtRaueXRBnoI14TmfGmb+1WPAY=";
    fetchSubmodules = true;
  };

  # Don't use #embed macro for chipdb binary embeddings - otherwise getting spurious type narrowing errors.
  # Maybe related to: https://github.com/llvm/llvm-project/issues/119256
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "check_cxx_compiler_hash_embed(HAS_HASH_EMBED CXX_FLAGS_HASH_EMBED)" ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
  ]
  ++ lib.optionals enableGui [
    wrapQtAppsHook
  ];

  buildInputs = [
    boostPython
    eigen
    python3Packages.apycula
  ]
  ++ lib.optionals enableGui [
    qtbase
  ]
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CURRENT_GIT_VERSION" finalAttrs.src.tag)
    (lib.cmakeFeature "ARCH" "generic;ice40;ecp5;himbaechel")
    (lib.cmakeBool "BUILD_TESTS" true)
    (lib.cmakeFeature "ICESTORM_INSTALL_PREFIX" icestorm.outPath)
    (lib.cmakeFeature "TRELLIS_INSTALL_PREFIX" trellis.outPath)
    (lib.cmakeFeature "TRELLIS_LIBDIR" "${lib.getLib trellis}/lib/trellis")
    (lib.cmakeFeature "GOWIN_BBA_EXECUTABLE" (lib.getExe' python3Packages.apycula "gowin_bba"))
    (lib.cmakeBool "USE_OPENMP" true)

    # gatemate excluded due to non-reproducible build https://github.com/YosysHQ/prjpeppercorn/issues/9
    # xilinx excluded due to needing vivado https://github.com/f4pga/prjxray?tab=readme-ov-file#step-1
    (lib.cmakeFeature "HIMBAECHEL_UARCH" "example;gowin;ng-ultra")

    (lib.cmakeFeature "HIMBAECHEL_GOWIN_DEVICES" "all")
    (lib.cmakeFeature "HIMBAECHEL_PRJBEYOND_DB" prjbeyond_src.outPath)
    # https://github.com/YosysHQ/nextpnr/issues/1578
    # `Compatibility with CMake < 3.5 has been removed from CMake.`
    # "CMAKE_POLICY_VERSION_MINIMUM=3.5"

    (lib.cmakeBool "BUILD_GUI" enableGui)
  ];

  doCheck = true;

  postFixup = lib.optionalString enableGui ''
    wrapQtApp $out/bin/nextpnr-generic
    wrapQtApp $out/bin/nextpnr-ice40
    wrapQtApp $out/bin/nextpnr-ecp5
    wrapQtApp $out/bin/nextpnr-himbaechel
  '';

  meta = {
    description = "Place and route tool for FPGAs";
    homepage = "https://github.com/yosyshq/nextpnr";
    changelog = "https://github.com/YosysHQ/nextpnr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.all;
  };
})

{
  lib,
  stdenv,
  bison,
  boost,
  callPackages,
  cmake,
  curl,
  eigen,
  fetchgit,
  fetchpatch,
  flex,
  gflags,
  glog,
  gmp,
  gtest,
  libunwind,
  metis,
  ninja,
  onetbb,
  onnxruntime,
  pkg-config,
  python3,
  tcl,
  yaml-cpp,
  zlib,
}:
let
  rootSrc = stdenv.mkDerivation {
    pname = "iEDA-src";
    version = "0.1.0-unstable-2025-12-23";

    src = fetchgit {
      url = "https://gitee.com/oscc-project/iEDA";
      rev = "59662dcd768165f3957003522cb929d42b252023";
      sha256 = "sha256-LaFGp9U7K+HmvHW1XK6HyUB/WM5O3y/tngul+cdbCP4=";
    };

    patches = [
      # This patch is to fix the build system to properly find and link against rust libraries.
      # Due to the way they organized the source code, it's hard to upstream this patch.
      # So we have to maintain this patch locally.
      (fetchpatch {
        hash = "sha256-YJnY+r9A887WT0a/H/Zf++r1PpD7t567NpkesDmIsD0=";
        url = "https://github.com/Emin017/iEDA/commit/e5f3ce024965df5e1d400b6a1d7f8b5b307a4bf3.patch";
      })
    ];

    postPatch = ''
      # Patch for boost1.89, should be removed after upstream update: https://gitee.com/oscc-project/iEDA/pulls/92
      sed -i '1i find_package(Boost REQUIRED)' src/operation/iPA/test/CMakeLists.txt
      sed -i 's/boost_system/Boost::headers/g' src/operation/iPA/test/CMakeLists.txt
    '';

    installPhase = ''
      cp -r . $out
    '';

    dontBuild = true;
    dontFixup = true;

  };

  rustpkgs = callPackages ./rustpkgs.nix { inherit rootSrc; };
in
stdenv.mkDerivation {
  pname = "iEDA";
  version = rootSrc.version;
  src = rootSrc;

  nativeBuildInputs = [
    cmake
    ninja
    flex
    bison
    python3
    tcl
    pkg-config
  ];

  buildInputs = [
    rustpkgs.iir-rust
    rustpkgs.sdf_parse
    rustpkgs.spef-parser
    rustpkgs.vcd_parser
    rustpkgs.verilog-parser
    rustpkgs.liberty-parser
    gtest
    glog
    gflags
    boost
    onnxruntime
    eigen
    yaml-cpp
    libunwind
    metis
    gmp
    tcl
    zlib
    curl
    onetbb
  ];

  cmakeFlags = [
    (lib.cmakeBool "CMD_BUILD" true)
    (lib.cmakeBool "SANITIZER" false)
    (lib.cmakeBool "BUILD_STATIC_LIB" false)
    (lib.cmakeOptionType "filepath" "CMAKE_RUNTIME_OUTPUT_DIRECTORY" "${placeholder "out"}/bin")
    (lib.cmakeOptionType "filepath" "CMAKE_LIBRARY_OUTPUT_DIRECTORY" "${placeholder "out"}/lib")
  ];

  postInstall = ''
    # Tests rely on hardcoded path, so they should not be included
    rm $out/bin/*test $out/bin/*Test $out/bin/test_* $out/bin/*_app

    # Copy scripts to the share directory for the test
    mkdir -p $out/share/scripts
    cp -r $src/scripts/hello.tcl $out/share/scripts/
  '';

  doInstallCheck = !stdenv.hostPlatform.isAarch64; # Tests will fail on aarch64-linux, wait for upstream fix: https://github.com/microsoft/onnxruntime/issues/10038

  installCheckPhase = ''
    runHook preInstallCheck

    # Run the tests
    $out/bin/iEDA -script $out/share/scripts/hello.tcl

    runHook postInstallCheck
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open-source EDA infracstructure and tools from Netlist to GDS for ASIC design";
    homepage = "https://gitee.com/oscc-project/iEDA";
    license = lib.licenses.mulan-psl2;

    maintainers = with lib.maintainers; [
      xinyangli
      Emin017
    ];

    platforms = lib.platforms.linux;
    mainProgram = "iEDA";
  };
}

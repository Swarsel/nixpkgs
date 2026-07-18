{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  applyPatches,
  cmake,
  dfu-util,
  fox_1_6,
  gtest,
  libsForQt5,
  llvmPackages,
  miniz,
  ninja,
  python3,
  replaceVars,
  udevCheckHook,
  yaml-cpp,
  # List of targets to build simulators for
  targetsToBuild ? import ./targets.nix,
}:

let
  # Keep in sync with `cmake/FetchMaxLibQt.cmake`.
  maxlibqt = fetchFromGitHub {
    hash = "sha256-u8e4qseU0+BJyZkV0JE4sUiXaFeIYvadkMTGXXiE2Kg=";
    owner = "edgetx";
    repo = "maxLibQt";
    rev = "ac1988ffd005cd15a8449b92150ce6c08574a4f1";
  };

  pythonEnv = python3.withPackages (
    pyPkgs: with pyPkgs; [
      pillow
      lz4
      jinja2
      clang
    ]
  );

  # paches are needed to fix build with CMake 4
  yaml-cppSrc = applyPatches {
    inherit (yaml-cpp) src;
    patches = yaml-cpp.patches or [ ];
  };
in

stdenv.mkDerivation (finalAttrs: {
  inherit targetsToBuild;
  pname = "edgetx";
  version = "2.11.3";

  src = fetchFromGitHub {
    owner = "EdgeTX";
    repo = "edgetx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vlJsfebTWhdh6HDpUEA1QJJSVGMlcL49XFwIx4A9zHs=";
    fetchSubmodules = true;
  };

  patches = [
    (replaceVars ./0001-libclang-paths.patch (
      let
        llvmMajor = lib.versions.major llvmPackages.llvm.version;
      in
      {
        libc-cflags = "${llvmPackages.clang}/nix-support/libc-cflags";
        libclang = "${lib.getLib llvmPackages.libclang}/lib/libclang.so";
        libcxx-cflags = "${llvmPackages.clang}/nix-support/libcxx-cxxflags";
        resourceDir = "${llvmPackages.clang.cc.lib}/lib/clang/${llvmMajor}";
      }
    ))
  ];

  postPatch = ''
    sed -i companion/src/burnconfigdialog.cpp \
      -e 's|/usr/.*bin/dfu-util|${dfu-util}/bin/dfu-util|'
    patchShebangs companion/util radio/util
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pythonEnv
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
    udevCheckHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtmultimedia
    libsForQt5.qtserialport
    SDL2
    fox_1_6
  ];

  cmakeFlags = [
    # Unvendoring these libraries is infeasible. At least lets reuse the same sources.
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_GOOGLETEST" "${gtest.src}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MINIZ" "${miniz.src}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_YAML-CPP" "${yaml-cppSrc}")
    # Custom library https://github.com/edgetx/maxLibQt.
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MAXLIBQT" "${maxlibqt}")
    (lib.cmakeFeature "DFU_UTIL_ROOT_DIR" "${lib.getBin dfu-util}/bin")
    # Superbuild machinery is only getting in the way.
    (lib.cmakeBool "EdgeTX_SUPERBUILD" false)
    # COMMON_OPTIONS from tools/build-companion.sh.
    (lib.cmakeBool "GVARS" true)
    (lib.cmakeBool "HELI" true)
    (lib.cmakeBool "LUA" true)
    # Build companion and not the firmware.
    (lib.cmakeBool "NATIVE_BUILD" true)
    # file RPATH_CHANGE could not write new RPATH.
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
  ];

  env = {
    EDGETX_VERSION_SUFFIX = "nixpkgs";
  };

  buildPhase = ''
    runHook preBuild

    cmakeCommonFlags="''${cmakeFlags[@]}"
    # This is the most sensible way to convert target name -> cmake options
    # aside from manually extracting bash variables from upstream's CI scripts
    # and converting that to nix expressions. Let's hope upstream doesn't break
    # this file too often.
    source $src/tools/build-common.sh

    # Yes, this is really how upstream expects packaging to look like ¯\_(ツ)_/¯.
    # https://github.com/EdgeTX/edgetx/wiki/Build-Instructions-under-Ubuntu-20.04#building-companion-simulator-and-radio-simulator-libraries
    for plugin in "''${targetsToBuild[@]}"
    do
      # Variable modified by `get_target_build_options` from build-common.sh.
      local BUILD_OPTIONS=""
      get_target_build_options "$plugin"
      # With each invocation of `cmakeConfigurePhase` `cmakeFlags` gets
      # prepended to, so it has to be reset.
      cmakeFlags=()
      appendToVar cmakeFlags $cmakeCommonFlags $BUILD_OPTIONS
      pushd .
      cmakeConfigurePhase
      ninjaFlags=("libsimulator")
      ninjaBuildPhase
      rm CMakeCache.txt
      popd
    done

    cmakeConfigurePhase
    ninjaFlags=()
    ninjaBuildPhase

    runHook postBuild
  '';

  doInstallCheck = true;
  __structuredAttrs = true; # To pass targetsToBuild as an array.

  configurePhase = ''
    runHook preConfigure
    prependToVar cmakeFlags "-GNinja"
    runHook postConfigure
  '';

  dontUseCmakeConfigure = true;

  meta = {
    description = "EdgeTX Companion transmitter support software";

    longDescription = ''
      EdgeTX Companion is used for many different tasks like loading EdgeTX
      firmware to the radio, backing up model settings, editing settings and
      running radio simulators.
    '';

    homepage = "https://edgetx.org/";
    changelog = "https://github.com/EdgeTX/edgetx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      lopsided98
      wucke13
      xokdvium
    ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "companion" + lib.concatStrings (lib.take 2 (lib.splitVersion finalAttrs.version));
  };
})

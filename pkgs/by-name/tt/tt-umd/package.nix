{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cmake,
  cxxopts,
  fmt,
  gtest,
  hwloc,
  nanobench,
  ninja,
  pkg-config,
  python3,
  spdlog,
  tt-logger,
  yaml-cpp,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tt-umd";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-umd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3IrgsKRaJP/rEXiMvi2LnzS9n2+Giu5d05RohzRgPw4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # https://github.com/tenstorrent/tt-umd/pull/2187
    ./fix-targets.patch
  ];

  postPatch = ''
    cp $cpm cmake/CPM.cmake
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    fmt
    yaml-cpp
    nanobench
    spdlog
    tt-logger
    cxxopts
    python3.pkgs.nanobind
    hwloc
    gtest
  ];

  cmakeFlags = [
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeBool "CPM_USE_LOCAL_PACKAGES_ONLY" true)
    (lib.cmakeBool "CPM_LOCAL_PACKAGES_ONLY" true)
    (lib.cmakeFeature "umd_asio_SOURCE_DIR" (
      builtins.toString (fetchFromGitHub {
        hash = "sha256-g+ZPKBUhBGlgvce8uTkuR983unD2kbQKgoddko7x+fk=";
        owner = "chriskohlhoff";
        repo = "asio";
        tag = "asio-1-30-2";
      })
    ))
    (lib.cmakeBool "TT_UMD_BUILD_TESTS" finalAttrs.doCheck)
    (lib.cmakeBool "TT_UMD_BUILD_STATIC" stdenv.hostPlatform.isStatic)
    (lib.cmakeBool "TT_UMD_BUILD_PYTHON" true)
    (lib.cmakeFeature "nanobind_DIR" "${python3.pkgs.nanobind}/${python3.sitePackages}/nanobind/cmake")
  ];

  doCheck = true;

  nativeCheckInputs = [
    gtest
  ];

  postInstall = ''
    mkdir -p $out/${python3.sitePackages}
    mv $out/tt_umd $out/${python3.sitePackages}/tt_umd
    rm $out/libtt-umd.so.*

    mkdir -p $out/${python3.sitePackages}/tt_umd-${finalAttrs.version}.dist-info
    cat > $out/${python3.sitePackages}/tt_umd-${finalAttrs.version}.dist-info/METADATA <<EOF
    Metadata-Version: 2.1
    Name: tt-umd
    Version: ${finalAttrs.version}
    EOF
  '';

  __structuredAttrs = true;

  cpm = fetchurl {
    hash = "sha256-yM3DLAOBZTjOInge1ylk3IZLKjSjENO3EEgSpcotg10=";
    url = "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake";
  };

  meta = {
    description = "User-Mode Driver for Tenstorrent hardware";
    homepage = "https://github.com/tenstorrent/tt-umd";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    platforms = lib.platforms.linux;
  };
})

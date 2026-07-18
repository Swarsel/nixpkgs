{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cmake,
  fmt_11,
  ninja,
  pkg-config,
  spdlog,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tt-logger";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-logger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Vd/FwjcNZWh/FnP5CwXO4UQtKTq/6GhRSppCYJMj9d4=";
  };

  patches = [
    # https://github.com/tenstorrent/tt-logger/pull/27
    ./fix-install.patch
  ];

  postPatch = ''
    cp $cpm cmake/CPM.cmake
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    fmt_11
    spdlog
  ];

  cmakeFlags = [
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeBool "CPM_USE_LOCAL_PACKAGES_ONLY" true)
    (lib.cmakeBool "CPM_LOCAL_PACKAGES_ONLY" true)
    (lib.cmakeBool "TT_LOGGER_INSTALL" true)
  ];

  __structuredAttrs = true;

  cpm = fetchurl {
    hash = "sha256-yM3DLAOBZTjOInge1ylk3IZLKjSjENO3EEgSpcotg10=";
    url = "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake";
  };

  meta = {
    description = "Flexible and performant C++ logging library for Tenstorrent projects";
    homepage = "https://github.com/tenstorrent/tt-logger";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    platforms = lib.platforms.linux;
  };
})

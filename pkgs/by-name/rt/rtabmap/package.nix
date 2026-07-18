{
  lib,
  stdenv,
  fetchFromGitHub,
  ceres-solver,
  # nativeBuildInputs
  cmake,
  eigen,
  freenect,
  g2o,
  # passthru
  gitUpdater,
  hidapi,
  libGL,
  libGLU,
  libdc1394,
  libice,
  liblapack,
  libnabo,
  libpointmatcher,
  librealsense,
  libsm,
  libusb1,
  libxt,
  octomap,
  # buildInputs
  opencv,
  pcl,
  pkg-config,
  qt6,
  vtkWithQt6,
  wrapGAppsHook3,
  yaml-cpp,
  zed-open-capture,
}:
let
  pcl' = pcl.override { vtk = vtkWithQt6; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rtabmap";
  version = "0.23.8";

  src = fetchFromGitHub {
    owner = "introlab";
    repo = "rtabmap";
    tag = finalAttrs.version;
    hash = "sha256-bVy/C6ZQdY7LmMW3vxxM5PCEtY/hBqrNsIdGcEulagU=";
  };

  # Fix boost 1.89 compatibility
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        "find_package(Boost COMPONENTS thread filesystem system program_options date_time chrono timer serialization REQUIRED)" \
        "find_package(Boost COMPONENTS thread filesystem program_options date_time chrono timer serialization REQUIRED)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    ## Required
    opencv
    opencv.cxxdev
    pcl'
    liblapack
    libsm
    libice
    libxt

    ## Optional
    libusb1
    eigen
    g2o
    ceres-solver
    yaml-cpp
    libnabo
    libpointmatcher
    octomap
    freenect
    libdc1394
    librealsense
    qt6.qtbase
    libGL
    libGLU
    zed-open-capture
    hidapi
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INCLUDE_PATH" "${pcl'}/include/pcl-${lib.versions.majorMinor pcl'.version}")
  ];

  # Configure environment variables
  env.NIX_CFLAGS_COMPILE = "-Wno-c++20-extensions";
  __structuredAttrs = true;

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Real-Time Appearance-Based 3D Mapping";
    homepage = "https://introlab.github.io/rtabmap/";
    changelog = "https://github.com/introlab/rtabmap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ marius851000 ];
    platforms = with lib.platforms; linux;
  };
})

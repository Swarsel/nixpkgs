{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  boost,
  # nativeBuildInputs
  cmake,
  config,
  cudaPackages,
  # buildInputs
  eigen,
  fetchpatch,
  flann,
  gitUpdater,
  libpcap,
  libpng,
  libtiff,
  libusb1,
  libxt,
  llvmPackages,
  nanoflann,
  pkg-config,
  qhull,
  qt6,
  vtk,
  cudaSupport ? config.cudaSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pcl";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "PointCloudLibrary";
    repo = "pcl";
    tag = "pcl-${finalAttrs.version}";
    hash = "sha256-+KyaajJM0I5CAcr8AiOLC4TkGV3Gm73a0/X8LQWFZMI=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-5vg8VjxoAfEOx9n7Tby1DXe1u4rn+zharkefUovLHv0=";
      # see https://github.com/NixOS/nixpkgs/issues/485826 to be removed at next release after 1.15.1
      name = "boost-1.89.patch";
      url = "https://github.com/PointCloudLibrary/pcl/commit/99333442ac63971297b4cdd05fab9d2bd2ff57a4.patch";
    })
  ];

  # remove attempt to prevent (x86/x87-specific) extended precision use
  # when SSE not detected
  postPatch = lib.optionalString (!stdenv.hostPlatform.isx86) ''
    sed -i '/-ffloat-store/d' cmake/pcl_find_sse.cmake
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
  ]
  ++ lib.optionals cudaSupport [ cudaPackages.cuda_nvcc ];

  buildInputs = [
    eigen
    libxt
    libpcap
    qt6.qtbase
    libusb1
    nanoflann
  ]
  ++ lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];

  propagatedBuildInputs = [
    boost
    flann
    libpng
    libtiff
    qhull
    vtk
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_CUDA" cudaSupport)
    (lib.cmakeBool "BUILD_GPU" cudaSupport)
    (lib.cmakeBool "PCL_ENABLE_MARCHNATIVE" false)
    (lib.cmakeBool "WITH_CUDA" cudaSupport)
  ];

  passthru.updateScript = gitUpdater {
    ignoredVersions = "rc";
    rev-prefix = "pcl-";
  };

  meta = {
    description = "Open project for 2D/3D image and point cloud processing";
    homepage = "https://pointclouds.org/";
    changelog = "https://github.com/PointCloudLibrary/pcl/blob/pcl-${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      GaetanLepage
      usertam
    ];

    platforms = with lib.platforms; linux ++ darwin;
  };
})

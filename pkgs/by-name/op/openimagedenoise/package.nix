{
  lib,
  stdenv,
  cmake,
  config,
  cudaPackages,
  fetchzip,
  ispc,
  onetbb,
  python3,
  xcodebuild,
  cudaSupport ? config.cudaSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openimagedenoise";
  version = "2.4.1";

  # The release tarballs include pretrained weights, which would otherwise need to be fetched with git-lfs
  src = fetchzip {
    url = "https://github.com/RenderKit/oidn/releases/download/v${finalAttrs.version}/oidn-${finalAttrs.version}.src.tar.gz";
    hash = "sha256-SM0Bn4qgeqRJAXr2MMjNjfWJVTcciERZxMHiyx4Z1hA=";
  };

  patches = lib.optionals cudaSupport [
    ./cuda.patch
  ];

  postPatch = ''
    # fix build failure with GCC14
    substituteInPlace cmake/oidn_platform.cmake \
      --replace-fail "set(CMAKE_CXX_STANDARD 11)" "set(CMAKE_CXX_STANDARD 14)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
    ispc
  ]
  ++ lib.optionals cudaSupport [ cudaPackages.cuda_nvcc ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcodebuild ];

  buildInputs = [
    onetbb
  ]

  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
    cudaPackages.cccl
  ];

  cmakeFlags = [
    (lib.cmakeBool "OIDN_DEVICE_CUDA" cudaSupport)
    (lib.cmakeFeature "TBB_INCLUDE_DIR" "${lib.getDev onetbb}/include")
    (lib.cmakeFeature "TBB_ROOT" "${onetbb}")
  ];

  meta = {
    description = "High-Performance Denoising Library for Ray Tracing";
    homepage = "https://www.openimagedenoise.org";
    changelog = "https://github.com/RenderKit/oidn/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.leshainc ];
    platforms = lib.platforms.unix;
  };
})

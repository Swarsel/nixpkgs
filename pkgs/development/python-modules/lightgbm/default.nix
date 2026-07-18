{
  lib,
  stdenv,
  boost187,
  buildPythonPackage,
  # optional-dependencies
  cffi,
  # nativeBuildInputs
  cmake,
  config,
  cudaPackages,
  dask,
  fetchPypi,
  # buildInputs
  llvmPackages,
  ninja,
  # dependencies
  numpy,
  ocl-icd,
  opencl-headers,
  pandas,
  pathspec,
  pkgs,
  pyarrow,
  pyproject-metadata,
  # build-system
  scikit-build-core,
  scikit-learn,
  scipy,
  writableTmpDirAsHomeHook,
  cudaSupport ? config.cudaSupport,
  # optionals: gpu
  gpuSupport ? stdenv.hostPlatform.isLinux && !cudaSupport,
}:

assert gpuSupport -> !cudaSupport;
assert cudaSupport -> !gpuSupport;

let
  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
in
buildPythonPackage.override { stdenv = effectiveStdenv; } (finalAttrs: {
  inherit (pkgs.lightgbm)
    pname
    version
    patches
    ;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-yxxZcg61aTicC6dNFPUjUbVzr0ifIwAyocnzFPi6t/4=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pathspec
    pyproject-metadata
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals cudaSupport [ cudaPackages.cuda_nvcc ];

  buildInputs =
    (lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ])
    ++ (lib.optionals gpuSupport [
      boost187
      ocl-icd
      opencl-headers
    ])
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_nvcc
      cudaPackages.cuda_cudart
    ];

  cmakeFlags = [
    (lib.cmakeBool "USE_GPU" gpuSupport)
    (lib.cmakeBool "USE_CUDA" cudaSupport)
    # Set in pyproject.toml for `cmake.args` in `[tool.scikit-build]`,
    # but not set by our hooks.
    (lib.cmakeBool "__BUILD_FOR_PYTHON" true)
  ]
  ++ lib.optionals cudaSupport [
    # build fails otherwise
    (lib.cmakeFeature "CMAKE_CUDA_STANDARD" "14")
  ];

  # No python tests
  doCheck = false;

  build-system = [
    scikit-build-core
  ];

  dependencies = [
    numpy
    scipy
  ];

  dontUseCmakeConfigure = true;

  optional-dependencies = {
    arrow = [
      cffi
      pyarrow
    ];

    dask = [
      dask
      pandas
    ]
    ++ dask.optional-dependencies.array
    ++ dask.optional-dependencies.dataframe
    ++ dask.optional-dependencies.distributed;

    pandas = [ pandas ];
    scikit-learn = [ scikit-learn ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lightgbm" ];

  meta = {
    description = "Fast, distributed, high performance gradient boosting (GBDT, GBRT, GBM or MART) framework";
    homepage = "https://github.com/lightgbm-org/LightGBM";
    changelog = "https://github.com/lightgbm-org/LightGBM/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flokli
      teh
    ];
  };
})

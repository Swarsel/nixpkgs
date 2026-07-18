{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  apache-tvm-ffi,
  # nativeBuildInputs
  autoPatchelfHook,
  buildPythonPackage,
  cloudpickle,
  # build-system
  cmake,
  cudaPackages,
  cython,
  # nativeCheckInputs
  einops,
  flash-linear-attention,
  # optional-dependencies,
  matplotlib,
  ml-dtypes,
  ninja,
  numpy,
  psutil,
  pytestCheckHook,
  python,
  pythonOlder,
  scikit-build-core,
  tilelang,
  torch,
  torch-c-dlpack-ext,
  tqdm,
  typing-extensions,
  writableTmpDirAsHomeHook,
  z3-solver,
  cudaSupport ? torch.cudaSupport,
}:
buildPythonPackage.override { inherit (torch) stdenv; } (finalAttrs: {
  pname = "tilelang";
  version = "0.1.11";

  src = fetchFromGitHub {
    owner = "tile-ai";
    repo = "tilelang";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C/c99/26/dBnQJYGrZ+NXl1Rqk3bjM2kpkgP/hWkTGE=";
    fetchSubmodules = true;
  };

  postPatch =
    # remove binary only packages from build-system.requires (pythonRelaxDeps
    # doesn't work)
    ''
      substituteInPlace pyproject.toml \
        --replace-fail '"z3-solver' '# "z3-solver' \
        --replace-fail '"patchelf' '# "patchelf'
    ''
    # don't call git
    + ''
      sed -i '/def get_git_commit_id()/a\\    return None' version_provider.py
    ''
    # fix permissions for install_name_tool -id
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace cmake/pypi-z3/FindZ3.cmake \
        --replace-fail COPYONLY 'FILE_PERMISSIONS
          OWNER_READ OWNER_WRITE OWNER_EXECUTE
          GROUP_READ GROUP_WRITE GROUP_EXECUTE
          WORLD_READ WORLD_WRITE WORLD_EXECUTE
          COPYONLY'
    '';

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvrtc # nvrtc.h
  ];

  cmakeFlags = [
    (lib.cmakeFeature "Z3_INCLUDE_DIR" "${z3-solver.dev}/include")
  ];

  env = {
    NO_GIT_VERSION = true;
    USE_CUDA = cudaSupport;
  };

  # requires GPU
  doCheck = false;

  nativeCheckInputs = [
    einops
    flash-linear-attention
    pytestCheckHook
  ];

  preFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      # libtvm_ffi.so
      addAutoPatchelfSearchPath "${finalAttrs.passthru.apache-tvm-ffi}/${python.sitePackages}/tvm_ffi/lib"
      # libz3.so.4.16
      addAutoPatchelfSearchPath "${z3-solver.lib}/lib"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # @rpath/libz3.dylib
      install_name_tool -add_rpath "${z3-solver.lib}/lib" \
        "$out/${python.sitePackages}/tilelang/lib/libtvm_compiler.dylib"
    '';

  __structuredAttrs = true;

  build-system = [
    cmake
    cython
    ninja
    scikit-build-core
  ];

  dependencies = [
    finalAttrs.passthru.apache-tvm-ffi
    cloudpickle
    ml-dtypes
    numpy
    psutil
    torch
    tqdm
    typing-extensions
    z3-solver
  ]
  ++ z3-solver.requiredPythonModules
  ++ lib.optionals (pythonOlder "3.14") [
    torch-c-dlpack-ext
  ];

  disabledTestPaths = [
    "3rdparty"
    # ImportError: cannot import name 'AutoModelForVision2Seq' from 'transformers'
    "examples/bitnet-1.58b/vllm_workspace"
    # FileNotFoundError: [Errno 2] No such file or directory: './old/bin/python'
    "maint/scripts/test_perf_regression.py"
  ];

  dontUseCmakeConfigure = true;

  optional-dependencies = {
    vis = [
      matplotlib
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tilelang" ];

  passthru.apache-tvm-ffi = apache-tvm-ffi.overrideAttrs (previousAttrs: {
    version = "0.1.10";

    src = previousAttrs.src.override {
      rev = "3c35034fd1026011736e19a4e0e1ed0f22058c42";
      tag = null;
      hash = "sha256-dqAO6RLLGIRzPk7dNQsQCck+ziyONddhK/t4+S28cn8=";
    };

    # fix eval
    meta.changelog = "";
  });

  passthru.gpuCheck = tilelang.overridePythonAttrs {
    doCheck = true;
    requiredSystemFeatures = [ "cuda" ];
  };

  meta = {
    description = "Tile level programming language to generate high performance code";
    homepage = "https://tilelang.com/";
    changelog = "https://github.com/tile-ai/tilelang/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      mit
      asl20 # 3rdparty/tvm
      bsd3 # 3rdparty/cutlass
    ];

    maintainers = with lib.maintainers; [ prince213 ];
    downloadPage = "https://github.com/tile-ai/tilelang/releases";
  };
})

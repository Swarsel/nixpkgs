{
  lib,
  stdenv,
  fetchFromGitHub,
  # CUDA-only dependencies:
  addDriverRunpath,
  autoAddDriverRunpath,
  buildPythonPackage,
  # CUDA flags:
  config,
  cudaPackages,
  # dependencies
  llvmlite,
  # tests
  numba,
  numpy,
  pytest-xdist,
  pytestCheckHook,
  python,
  replaceVars,
  # nativeBuildInputs
  setuptools,
  writableTmpDirAsHomeHook,
  writers,
  cudaSupport ? config.cudaSupport,
  doFullCheck ? false,
  testsWithoutSandbox ? false,
}:

let
  cudatoolkit = cudaPackages.cuda_nvcc;
in
buildPythonPackage (finalAttrs: {
  pname = "numba";
  version = "0.65.1";

  src = fetchFromGitHub {
    owner = "numba";
    repo = "numba";
    tag = finalAttrs.version;
    hash = "sha256-DMmUyTElDFyMK4BUQ4EhDNmG43lOWQHurKbnSyhAs5k=";

    # Upstream uses .gitattributes to inject information about the revision
    # hash and the refname into `numba/_version.py`, see:
    #
    # - https://git-scm.com/docs/gitattributes#_export_subst and
    # - https://github.com/numba/numba/blame/5ef7c86f76a6e8cc90e9486487294e0c34024797/numba/_version.py#L25-L31
    postFetch = ''
      sed -i 's/git_refnames = "[^"]*"/git_refnames = " (tag: ${finalAttrs.src.tag})"/' $out/numba/_version.py
    '';
  };

  patches = [
    ./numpy2.5.patch
  ]
  ++ lib.optionals cudaSupport [
    (replaceVars ./cuda_path.patch {
      cuda_toolkit_lib_path = lib.getLib cudatoolkit;
      cuda_toolkit_path = cudatoolkit;
    })
  ];

  postPatch = ''
    substituteInPlace numba/cuda/cudadrv/driver.py \
      --replace-fail \
        "dldir = [" \
        "dldir = [ '${addDriverRunpath.driverLink}/lib', "

    substituteInPlace setup.py \
      --replace-fail 'max_numpy_run_version = "2.5"' 'max_numpy_run_version = "2.6"'
    substituteInPlace numba/__init__.py \
      --replace-fail "(2, 4)" "(2, 6)"
  '';

  nativeBuildInputs = lib.optionals cudaSupport [
    autoAddDriverRunpath
    cudaPackages.cuda_nvcc
  ];

  buildInputs = lib.optionals cudaSupport [ cudaPackages.cuda_cudart ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    writableTmpDirAsHomeHook
  ];

  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    cd $out
  '';

  build-system = [
    setuptools
    numpy
  ];

  dependencies = [
    numpy
    llvmlite
  ];

  disabledTestPaths = lib.optionals (!testsWithoutSandbox) [
    # See NOTE near passthru.tests.withoutSandbox
    "${python.sitePackages}/numba/cuda/tests"
  ];

  disabledTests = lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # captured stderr: Fatal Python error: Segmentation fault
    "test_sum1d_pyobj"
  ];

  enabledTestPaths =
    if doFullCheck then
      null
    else
      [
        # These are the most basic tests. Running all tests is too expensive, and
        # some of them fail (also differently on different platforms), so it will
        # be too hard to maintain such a `disabledTests` list.
        "${python.sitePackages}/numba/tests/test_usecases.py"
      ];

  pyproject = true;
  pythonImportsCheck = [ "numba" ];

  pythonRelaxDeps = [
    "numpy"
  ];

  passthru.testers.cuda-detect =
    writers.writePython3Bin "numba-cuda-detect"
      { libraries = [ (numba.override { cudaSupport = true; }) ]; }
      ''
        from numba import cuda
        cuda.detect()
      '';

  passthru.tests = {
    withSandbox = numba.override {
      cudaSupport = false;
      doFullCheck = true;
      testsWithoutSandbox = false;
    };

    # CONTRIBUTOR NOTE: numba also contains CUDA tests, though these cannot be run in
    # this sandbox environment. Consider building the derivation below with
    # --no-sandbox to get a view of how many tests succeed outside the sandbox.
    withoutSandbox = numba.override {
      cudaSupport = true;
      doFullCheck = true;
      testsWithoutSandbox = true;
    };
  };

  meta = {
    description = "Compiling Python code using LLVM";
    homepage = "https://numba.pydata.org/";
    changelog = "https://numba.readthedocs.io/en/stable/release/${finalAttrs.version}-notes.html";
    license = lib.licenses.bsd2;
    mainProgram = "numba";
  };
})

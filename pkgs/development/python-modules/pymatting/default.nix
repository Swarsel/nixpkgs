{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  config,
  # cuda-only
  cupy,
  # dependencies
  numba,
  numpy,
  pillow,
  # tests
  pocl,
  pyopencl,
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
  cudaSupport ? config.cudaSupport,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymatting";
  version = "1.1.15";

  src = fetchFromGitHub {
    owner = "pymatting";
    repo = "pymatting";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rcatlQE+YgppY//ZgGY9jO5KI0ED30fLlqW9N+xRNqk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.optionals cudaSupport [
    # Provides a CPU-based OpenCL ICD so that pyopencl's module-level
    # cl.create_some_context() succeeds without GPU hardware.
    pocl
    # pocl needs a writable $HOME for its kernel cache directory.
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    numba
    numpy
    pillow
    scipy
  ]
  ++ lib.optionals cudaSupport [
    cupy
    pyopencl
  ];

  disabledTestPaths = lib.optionals cudaSupport [
    # Requires a CUDA driver for cupy GPU operations
    "tests/test_foreground.py"
  ];

  disabledTests = [
    # no access to input data set
    # see: https://github.com/pymatting/pymatting/blob/master/tests/download_images.py
    "test_alpha"
    "test_laplacians"
    "test_preconditioners"
    "test_lkm"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymatting" ];

  meta = {
    description = "Python library for alpha matting";
    homepage = "https://github.com/pymatting/pymatting";
    changelog = "https://github.com/pymatting/pymatting/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})

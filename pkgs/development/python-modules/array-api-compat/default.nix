{
  lib,
  fetchFromGitHub,
  # tests
  array-api-strict,
  buildPythonPackage,
  config,
  cupy,
  dask,
  jax,
  jaxlib,
  numpy,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  sparse,
  torch,
  cudaSupport ? config.cudaSupport,
}:

buildPythonPackage rec {
  pname = "array-api-compat";
  version = "1.14";

  src = fetchFromGitHub {
    owner = "data-apis";
    repo = "array-api-compat";
    tag = version;
    hash = "sha256-Dhiq6GWxVm9BEeO81VSa3L644gp00LxFPJAliz8LbAE=";
  };

  nativeCheckInputs = [
    array-api-strict
    dask
    jax
    jaxlib
    numpy
    pytestCheckHook
    sparse
    torch
  ]
  ++ lib.optionals cudaSupport [ cupy ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  # CUDA (used via cupy) is not available in the testing sandbox
  disabledTests = [
    "cupy"
  ];

  pyproject = true;
  pythonImportsCheck = [ "array_api_compat" ];

  meta = {
    description = "Compatibility layer for NumPy to support the Python array API";
    homepage = "https://data-apis.org/array-api-compat";
    changelog = "https://github.com/data-apis/array-api-compat/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ berquist ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  dask,
  # dependencies
  numba,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "sparse";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "pydata";
    repo = "sparse";
    tag = finalAttrs.version;
    hash = "sha256-HHZ47TAgNbEEZj1sEe85yQRleW4Un2wfwQyFp4BPCbI=";
  };

  nativeCheckInputs = [
    dask
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numba
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "sparse" ];

  meta = {
    description = "Sparse n-dimensional arrays computations";
    homepage = "https://sparse.pydata.org/";
    changelog = "https://sparse.pydata.org/en/stable/changelog.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    downloadPage = "https://github.com/pydata/sparse/releases/tag/${finalAttrs.src.tag}";
  };
})

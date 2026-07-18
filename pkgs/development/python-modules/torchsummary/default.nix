{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  numpy,
  # build-system
  setuptools,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "torchsummary";
  version = "1.5.1";

  # No tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-mBv2ieIuDPf5XHRgAvIKJK0mqmudhhE0oUvGzpIjBZA=";
  };

  # no tests in pypi tarball
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "torchsummary" ];

  meta = {
    description = "Model summary in PyTorch similar to `model.summary()` in Keras";
    homepage = "https://github.com/sksq96/pytorch-summary";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})

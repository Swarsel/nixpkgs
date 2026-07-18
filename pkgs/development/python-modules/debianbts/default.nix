{
  lib,
  buildPythonPackage,
  distutils,
  fetchPypi,
  pysimplesoap,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-debianbts";
  version = "4.1.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-9EOxjOJBGzcxA3hHFeZwffA09I2te+OHppF7FuFU15M=";
    pname = "python_debianbts";
  };

  postPatch = ''
    sed -i "/--cov/d" pyproject.toml
  '';

  # Most tests require network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pysimplesoap
    distutils
  ];

  pyproject = true;
  pythonImportsCheck = [ "debianbts" ];

  meta = {
    description = "Python interface to Debian's Bug Tracking System";
    homepage = "https://github.com/venthur/python-debianbts";
    changelog = "https://github.com/venthur/python-debianbts/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nicoo ];
    mainProgram = "debianbts";
    downloadPage = "https://pypi.org/project/python-debianbts/";
  };
})

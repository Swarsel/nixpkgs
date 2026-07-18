{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynina";
  version = "1.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-ypbfvhXKu4pKr/DrWFnAhwMoqShJzWLqlA7/YQzJ9r4=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pynina" ];
  pythonRelaxDeps = [ "aiohttp" ];

  meta = {
    description = "Python API wrapper to retrieve warnings from the german NINA app";
    homepage = "https://gitlab.com/DeerMaximum/pynina";
    changelog = "https://gitlab.com/DeerMaximum/pynina/-/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

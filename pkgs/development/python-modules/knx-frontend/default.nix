{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "knx-frontend";
  version = "2026.7.8.100603";

  # TODO: source build, uses yarn.lock
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-80yeDZ8a8WDf/NEXjFSkcfpglp9yTnmg+4csFbgdFpM=";
    pname = "knx_frontend";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "knx_frontend" ];

  meta = {
    description = "Home Assistant Panel for managing the KNX integration";
    homepage = "https://github.com/XKNX/knx-frontend";
    changelog = "https://github.com/XKNX/knx-frontend/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})

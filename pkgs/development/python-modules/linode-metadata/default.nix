{
  lib,
  buildPythonPackage,
  fetchPypi,
  httpx,
  linode-cli,
  pytest,
  pytest-asyncio,
  setuptools,
}:

buildPythonPackage rec {
  pname = "linode-metadata";
  version = "0.3.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-fYPhZ3FzzEyHAhJsfAzgnWeAF/0k/di4Ce+MNiu7gP4=";
    pname = "linode_metadata";
  };

  checkInputs = [
    pytest
    pytest-asyncio
  ];

  dependencies = [
    httpx
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "linode_metadata" ];

  meta = {
    description = "Python package for interacting with the Linode Metadata Service";
    homepage = "https://github.com/linode/py-metadata";
    changelog = "https://github.com/linode/py-metadata/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = linode-cli.meta.maintainers;
    downloadPage = "https://pypi.org/project/linode-metadata/";
  };
}

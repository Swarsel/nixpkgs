{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "faadelays";
  version = "2023.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ngMFd+BE3hKeaeGEX4xHpzDIrtGFDsSwxBbrc4ZMFas=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ aiohttp ];
  # Project has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "faadelays" ];

  meta = {
    description = "Python package to retrieve FAA airport status";
    homepage = "https://github.com/ntilley905/faadelays";
    changelog = "https://github.com/ntilley905/faadelays/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

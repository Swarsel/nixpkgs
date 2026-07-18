{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  tenacity,
}:

buildPythonPackage rec {
  pname = "py-aosmith";
  version = "1.0.18";

  src = fetchFromGitHub {
    owner = "bdr99";
    repo = "py-aosmith";
    tag = version;
    hash = "sha256-sR7yUl97MlxdJHLrA8IjODNk7LJhVxqraaUkPljuMZg=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    tenacity
  ];

  pyproject = true;
  pythonImportsCheck = [ "py_aosmith" ];

  meta = {
    description = "Python client library for A. O. Smith water heaters";
    homepage = "https://github.com/bdr99/py-aosmith";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

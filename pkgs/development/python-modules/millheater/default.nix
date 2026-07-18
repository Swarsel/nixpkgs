{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pyjwt,
  setuptools,
}:

buildPythonPackage rec {
  pname = "millheater";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pymill";
    tag = version;
    hash = "sha256-7Jqk5WarCA/YBpmFuF4/dbWpQHtKKRH8hYRT2FXn2n8=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "mill" ];

  meta = {
    description = "Python library for Mill heater devices";
    homepage = "https://github.com/Danielhiversen/pymill";
    changelog = "https://github.com/Danielhiversen/pymill/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

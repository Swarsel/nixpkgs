{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyrympro";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "OnFreund";
    repo = "pyrympro";
    tag = "v${version}";
    hash = "sha256-+KgYdiVuX8Ycw0Odte/EXsoWiMaLmTU6zTeJCw9jwvs=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyrympro" ];

  meta = {
    description = "Module to interact with Read Your Meter Pro";
    homepage = "https://github.com/OnFreund/pyrympro";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

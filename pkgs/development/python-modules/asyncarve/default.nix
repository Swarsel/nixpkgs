{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  mashumaro,
  orjson,
  setuptools,
  yarl,
}:

buildPythonPackage rec {
  pname = "asyncarve";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5h56Sr0kPLrNPU70W90WsjmWax/N90dRMJ6lI5Mg86E=";
  };

  # No tests in repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    mashumaro
    orjson
    aiohttp
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "asyncarve" ];

  meta = {
    description = "Simple Arve library";
    homepage = "https://github.com/arvetech/asyncarve";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
  };
}

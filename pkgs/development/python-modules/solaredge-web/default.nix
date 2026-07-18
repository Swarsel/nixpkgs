{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "solaredge-web";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Solarlibs";
    repo = "solaredge-web";
    tag = "v${version}";
    hash = "sha256-bONCD7dE8U0Y55UuQ0VYQE5r/q7ihtki33ZkPssiIJ4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "solaredge_web" ];

  meta = {
    description = "Library for fetching SolarEdge energy data for each inverter/string/module via the web API";
    homepage = "https://github.com/Solarlibs/solaredge-web";
    changelog = "https://github.com/Solarlibs/solaredge-web/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}

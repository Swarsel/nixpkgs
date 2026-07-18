{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
}:

buildPythonPackage rec {
  pname = "tessie-api";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "andrewgierens";
    repo = "tessie_python_api";
    tag = version;
    hash = "sha256-Ia5J7dGbcfEa6rEKyJzEnzVnMC3HyI7l5g20v7d7Gjo=";
  };

  # Tests require API credentials
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "tessie_api" ];

  meta = {
    description = "Python wrapper for the Tessie API";
    homepage = "https://github.com/andrewgierens/tessie_python_api";
    changelog = "https://github.com/andrewgierens/tessie_python_api/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}

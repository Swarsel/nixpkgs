{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "vegehub";
  version = "0.1.26";

  src = fetchFromGitHub {
    owner = "Thulrus";
    repo = "VegeHubPyPiLib";
    tag = "V${version}";
    hash = "sha256-OrHUT1WchsaoPNFBZn74jpihd8I/R1RB0+KZRKg9Zrs=";
  };

  postPatch = ''
    rm -r dist
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "vegehub" ];

  meta = {
    description = "Basic package for simplifying interactions with the Vegetronix VegeHub";
    homepage = "https://github.com/Thulrus/VegeHubPyPiLib";
    changelog = "https://github.com/Thulrus/VegeHubPyPiLib/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

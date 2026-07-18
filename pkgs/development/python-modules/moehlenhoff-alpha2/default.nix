{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "moehlenhoff-alpha2";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "j-a-n";
    repo = "python-moehlenhoff-alpha2";
    tag = version;
    hash = "sha256-bvT7kWFPIEQUgUxLGydd2e7SBA7vPV+YAzDqYLE7X+o=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    xmltodict
  ];

  pyproject = true;

  pythonImportsCheck = [
    "moehlenhoff_alpha2"
  ];

  meta = {
    description = "Python client for the Moehlenhoff Alpha2 underfloor heating system";
    homepage = "https://github.com/j-a-n/python-moehlenhoff-alpha2";
    changelog = "https://github.com/j-a-n/python-moehlenhoff-alpha2/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}

{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyemoncms";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "Open-Building-Management";
    repo = "pyemoncms";
    tag = "v${version}";
    hash = "sha256-Bvcnl3av9SF0CNUjg/QDdvENIEgPg26fAJ522jBrL7Q=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];

  disabledTests = [
    # requires networking
    "test_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyemoncms" ];

  meta = {
    description = "Python library for emoncms API";
    homepage = "https://github.com/Open-Building-Management/pyemoncms";
    changelog = "https://github.com/Open-Building-Management/pyemoncms/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

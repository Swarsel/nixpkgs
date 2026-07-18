{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "pycync";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Kinachi249";
    repo = "pycync";
    tag = "v${version}";
    hash = "sha256-mYHUkenP0FMnwKOdZe4XjC/VnP3JJGPtuVdYR9UcouM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    cd tests
  '';

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
  ];

  disabled = pythonOlder "3.13";
  pyproject = true;
  pythonImportsCheck = [ "pycync" ];

  meta = {
    description = "Python API library for Cync smart devices";
    homepage = "https://github.com/Kinachi249/pycync";
    changelog = "https://github.com/Kinachi249/pycync/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}

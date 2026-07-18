{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  cryptography,
  pyjwt,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyanglianwater";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "pantherale0";
    repo = "pyanglianwater";
    tag = version;
    hash = "sha256-AkdWWiw1FMs/uuJNSocMBpReXY2mrxouQfWuu4ntRWY=";
  };

  # tests are out of date
  doCheck = false;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    cryptography
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyanglianwater" ];

  meta = {
    description = "Python API to interact with Anglian Water";
    homepage = "https://github.com/pantherale0/pyanglianwater";
    changelog = "https://github.com/pantherale0/pyanglianwater/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}

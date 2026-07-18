{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiopvapi";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "sander76";
    repo = "aio-powerview-api";
    tag = "v${version}";
    hash = "sha256-yystaH2HRsJoYh2aTpOBA7DLiC2xwpBUccHwmJ0FlaY=";
  };

  patches = [
    # https://github.com/sander76/aio-powerview-api/pull/46
    ./fix-tests.patch
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aiopvapi" ];

  meta = {
    description = "Python API for the PowerView API";
    homepage = "https://github.com/sander76/aio-powerview-api";
    changelog = "https://github.com/sander76/aio-powerview-api/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}

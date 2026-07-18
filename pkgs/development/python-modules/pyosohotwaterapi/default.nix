{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  loguru,
  numpy,
  setuptools,
  unasync,
  urllib3,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pyosohotwaterapi";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "osohotwateriot";
    repo = "apyosohotwaterapi";
    tag = version;
    hash = "sha256-hpbmiSOLawKVSh7BGV70bRi45HCDKmdxEEhCOdJuIww=";
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    setuptools
    unasync
    writableTmpDirAsHomeHook
  ];

  dependencies = [
    aiohttp
    loguru
    numpy
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "apyosoenergyapi" ];

  meta = {
    description = "Module for using the OSO Hotwater API";
    homepage = "https://github.com/osohotwateriot/apyosohotwaterapi";
    changelog = "https://github.com/osohotwateriot/apyosohotwaterapi/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

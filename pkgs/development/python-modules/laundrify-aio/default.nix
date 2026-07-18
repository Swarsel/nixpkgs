{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pyjwt,
  setuptools,
}:

buildPythonPackage rec {
  pname = "laundrify-aio";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "laundrify";
    repo = "laundrify-pypi";
    tag = "v${version}";
    hash = "sha256-iFQ0396BkGWM7Ma/I0gbXucd2/yPmEVF4IC3/bMK2SA=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "laundrify_aio" ];

  meta = {
    description = "Module to communicate with the laundrify API";
    homepage = "https://github.com/laundrify/laundrify-pypi";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}

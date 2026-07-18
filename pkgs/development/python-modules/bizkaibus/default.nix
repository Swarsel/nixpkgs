{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bizkaibus";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "UgaitzEtxebarria";
    repo = "BizkaibusRTPI";
    rev = version;
    hash = "sha256-TM02pSSOELRGSwsKc5C+34W94K6mnS0C69aijsPqSWs=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "bizkaibus" ];

  meta = {
    description = "Python module to get information about Bizkaibus buses";
    homepage = "https://github.com/UgaitzEtxebarria/BizkaibusRTPI";
    changelog = "https://github.com/UgaitzEtxebarria/BizkaibusRTPI/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

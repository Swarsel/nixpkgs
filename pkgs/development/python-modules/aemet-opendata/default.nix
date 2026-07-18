{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  geopy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aemet-opendata";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "Noltari";
    repo = "AEMET-OpenData";
    tag = version;
    hash = "sha256-xxpB5JFPkTwd7dxba9pXRvcont/i3wXBdJh5NfLnZTM=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    geopy
  ];

  pyproject = true;
  pythonImportsCheck = [ "aemet_opendata.interface" ];

  meta = {
    description = "Python client for AEMET OpenData Rest API";
    homepage = "https://github.com/Noltari/AEMET-OpenData";
    changelog = "https://github.com/Noltari/AEMET-OpenData/releases/tag/${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

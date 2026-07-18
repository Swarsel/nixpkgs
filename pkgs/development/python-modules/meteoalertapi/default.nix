{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "meteoalertapi";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "rolfberkenbosch";
    repo = "meteoalert-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Imb4DVcNB3QiVSCLCI+eKpfl73aMn4NIItQVf7p0H+E=";
  };

  propagatedBuildInputs = [
    requests
    xmltodict
  ];

  # Tests require network access
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "meteoalertapi" ];

  meta = {
    description = "Python wrapper for MeteoAlarm.org";
    homepage = "https://github.com/rolfberkenbosch/meteoalert-api";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})

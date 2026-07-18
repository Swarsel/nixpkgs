{
  lib,
  buildPythonPackage,
  certifi,
  fetchPypi,
  python-dateutil,
  six,
  urllib3,
}:

buildPythonPackage rec {
  pname = "cloudsmith-api";
  version = "2.0.23";

  src = fetchPypi {
    inherit format version;
    hash = "sha256-CfNgISONtTrabCoNUzHbMMVKDwGj8fdmSwh1FfzH10g=";
    pname = "cloudsmith_api";
  };

  propagatedBuildInputs = [
    certifi
    python-dateutil
    six
    urllib3
  ];

  # Wheels have no tests
  doCheck = false;
  format = "wheel";
  pythonImportsCheck = [ "cloudsmith_api" ];

  meta = {
    description = "Cloudsmith API Client";
    homepage = "https://github.com/cloudsmith-io/cloudsmith-api";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ usertam ];
  };
}

{
  lib,
  asn1crypto,
  buildPythonPackage,
  certifi,
  fetchPypi,
  python-dateutil,
  setuptools,
  six,
  urllib3,
}:

buildPythonPackage rec {
  pname = "ionoscloud";
  version = "6.1.13";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8QgweGXPWcvGQcp22yo4KovkVXrDI2eSWNMUnGhDWEI=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    urllib3
    six
    certifi
    python-dateutil
    asn1crypto
  ];

  # upstream only has codecoverage tests, but no actual tests to go with them
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "ionoscloud" ];

  meta = {
    description = "Python API client for ionoscloud";
    homepage = "https://github.com/ionos-cloud/sdk-python";
    changelog = "https://github.com/ionos-cloud/sdk-python/blob/v${version}/docs/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

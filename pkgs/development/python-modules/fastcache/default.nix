{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fastcache";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-beGxbnAzW3veJmcH60AaOq7CIPtmxdE7Aqvw6ri+eCs=";
  };

  nativeCheckInputs = [ pytest ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "fastcache" ];

  meta = {
    description = "C implementation of Python3 lru_cache";
    homepage = "https://github.com/pbrady/fastcache";
    changelog = "https://github.com/pbrady/fastcache/blob/v${version}/CHANGELOG";
    license = lib.licenses.mit;
  };
}

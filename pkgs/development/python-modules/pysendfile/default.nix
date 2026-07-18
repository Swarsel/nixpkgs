{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysendfile";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UQpBSycJhvujx5y3bZCkyRDHAb+0P/mDpdTpKEYFDhc=";
  };

  # Tests depend on asynchat and asyncore
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "sendfile" ];

  meta = {
    description = "Python interface to sendfile(2)";
    homepage = "https://github.com/giampaolo/pysendfile";
    changelog = "https://github.com/giampaolo/pysendfile/blob/release-${version}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

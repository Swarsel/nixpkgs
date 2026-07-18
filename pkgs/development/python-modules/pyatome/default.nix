{
  lib,
  buildPythonPackage,
  fake-useragent,
  fetchPypi,
  requests,
  simplejson,
}:

buildPythonPackage rec {
  pname = "pyatome";
  version = "0.1.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DGkgW6emh/esZa/alUjBbpLXlU4EVIPkysn9a0LgcJ4=";
    pname = "pyAtome";
  };

  propagatedBuildInputs = [
    requests
    simplejson
    fake-useragent
  ];

  # No tests in PyPI tarballs
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyatome" ];

  meta = {
    description = "Python module to get energy consumption data from Atome";
    homepage = "https://github.com/baqs/pyAtome";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ uvnikita ];
    mainProgram = "pyatome";
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  icmplib,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fastdotcom";
  version = "0.0.7";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ozQ0d1CIIsMOdvK9UhRnr2c2fmIzkZcpjZrjZjfnknI=";
    pname = "fastdotcom";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    icmplib
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastdotcom" ];

  meta = {
    description = "Python API for testing internet speed on Fast.com";
    homepage = "https://github.com/nkgilley/fast.com";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}

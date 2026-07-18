{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytest,
  pytest-arraydiff,
  pytest-astropy-header,
  pytest-cov,
  pytest-doctestplus,
  pytest-filter-subpackage,
  pytest-mock,
  pytest-remotedata,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-astropy";
  version = "0.11.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Tq6qme2RFj7Y+arBMscKgfJbxMEvPNVNujKfwmxnObU=";
  };

  buildInputs = [ pytest ];
  # pytest-astropy is a meta package that only propagates requirements
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    hypothesis
    pytest-arraydiff
    pytest-astropy-header
    pytest-cov
    pytest-doctestplus
    pytest-filter-subpackage
    pytest-mock
    pytest-remotedata
  ];

  pyproject = true;

  meta = {
    description = "Meta-package containing dependencies for testing";
    homepage = "https://github.com/astropy/pytest-astropy";
    changelog = "https://github.com/astropy/pytest-astropy/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

{
  lib,
  black,
  buildPythonPackage,
  fetchPypi,
  pytest,
  setuptools-scm,
  toml,
}:

buildPythonPackage rec {
  pname = "pytest-black";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    sha256 = "sha256-7Ld0VfN5gFy0vY9FqBOjdUw7vuMZmt8bNmXA39CGtRE=";
    pname = "pytest_black";
  };

  buildInputs = [ pytest ];
  # does not contain tests
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    black
    toml
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pytest_black" ];

  meta = {
    description = "Pytest plugin to enable format checking with black";
    homepage = "https://github.com/shopkeep/pytest-black";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

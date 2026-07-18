{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "plaster";
  version = "1.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+L78VL+MEUfBCrQCl+yEwmdvotTqXW9STZQ2qAB075g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  format = "setuptools";

  meta = {
    description = "Loader interface around multiple config file formats";
    homepage = "https://pypi.org/project/plaster/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

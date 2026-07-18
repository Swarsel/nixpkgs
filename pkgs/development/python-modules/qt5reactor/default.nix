{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyqt5,
  pytest-twisted,
  pytestCheckHook,
  pythonAtLeast,
  twisted,
}:

buildPythonPackage rec {
  pname = "qt5reactor";
  version = "0.6.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "c3470a8a25d9a339f9ca6243502a9b2277f181d772b7acbff551d5bc363b7572";
  };

  propagatedBuildInputs = [
    pyqt5
    twisted
  ];

  nativeCheckInputs = [
    pytest-twisted
    pytestCheckHook
  ];

  # AttributeError: module 'configparser' has no attribute 'SafeConfigParser'
  disabled = pythonAtLeast "3.12";
  format = "setuptools";
  pythonImportsCheck = [ "qt5reactor" ];

  meta = {
    description = "Twisted Qt Integration";
    homepage = "https://github.com/twisted/qt5reactor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

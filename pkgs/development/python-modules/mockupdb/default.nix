{
  lib,
  buildPythonPackage,
  fetchPypi,
  pymongo,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "mockupdb";
  version = "1.8.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-020OW2RF/5FB400BL6K13+WJhHqh4+y413QHSWKvlE4=";
  };

  propagatedBuildInputs = [ pymongo ];
  nativeCheckInputs = [ pytestCheckHook ];
  # use the removed ssl.wrap_socket function
  disabled = pythonAtLeast "3.12";

  disabledTests = [
    # AssertionError: expected to receive Request(), got nothing
    "test_flags"
    "test_iteration"
    "test_ok"
    "test_ssl_basic"
    "test_unix_domain_socket"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "mockupdb" ];

  meta = {
    description = "Simulate a MongoDB server";
    homepage = "https://github.com/ajdavis/mongo-mockup-db";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

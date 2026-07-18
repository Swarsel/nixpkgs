{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytestCheckHook,
  six,
  strict-rfc3339,
}:

buildPythonPackage rec {
  pname = "rfc3339-validator";
  version = "0.1.4";

  src = fetchPypi {
    inherit version;
    sha256 = "0srg0b89aikzinw72s433994k5gv5lfyarq1adhas11kz6yjm2hk";
    pname = "rfc3339_validator";
  };

  propagatedBuildInputs = [ six ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    strict-rfc3339
  ];

  format = "setuptools";
  pythonImportsCheck = [ "rfc3339_validator" ];

  meta = {
    description = "RFC 3339 validator for Python";
    homepage = "https://github.com/naimetti/rfc3339-validator";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  pdfrw,
}:

buildPythonPackage (finalAttrs: {
  pname = "pagelabels";
  version = "1.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-GAEyhECToKnIWBxnYTSOsYKZBjl50b/82mZ68i8I2ug=";
  };

  # upstream doesn't contain tests
  doCheck = false;

  dependencies = [
    pdfrw
  ];

  format = "setuptools";

  meta = {
    description = "Python library to manipulate PDF page labels";
    homepage = "https://github.com/lovasoa/pagelabels-py";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ teto ];
  };
})

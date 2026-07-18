{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "calmjs-types";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-EGWYv9mx3RPqs9dnB5t3Bu3hiujL2y/XxyMP7JkjjAQ=";
    extension = "zip";
    pname = "calmjs.types";
  };

  checkInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "calmjs.types" ];

  meta = {
    description = "Types for the calmjs framework";
    homepage = "https://github.com/calmjs/calmjs.types";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}

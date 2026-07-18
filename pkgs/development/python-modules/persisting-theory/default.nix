{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "persisting-theory";
  version = "1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-D4QPoiJHvKpRQJTafzsmxgI1lCmrEtLNiL4GtJozYpA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "persisting_theory" ];

  meta = {
    description = "Automate data discovering and access inside a list of packages";
    homepage = "https://code.agate.blue/agate/persisting-theory";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

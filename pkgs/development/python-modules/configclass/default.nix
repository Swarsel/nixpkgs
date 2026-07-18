{
  lib,
  buildPythonPackage,
  fetchPypi,
  mergedict,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "configclass";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aoDKBuDxJCeXbVwCXhse6FCbDDM30/Xa8p9qRvDkWBk=";
  };

  propagatedBuildInputs = [ mergedict ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "configclass" ];

  meta = {
    description = "Python to class to hold configuration values";
    homepage = "https://github.com/schettino72/configclass/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}

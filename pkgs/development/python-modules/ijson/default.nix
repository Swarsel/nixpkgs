{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  yajl,
}:

buildPythonPackage rec {
  pname = "ijson";
  version = "3.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-r0C9GoX1XbC4swcVyFh2Ewa9ktVZAUhjb3XDMJ5udr0=";
  };

  buildInputs = [ yajl ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "ijson" ];

  meta = {
    description = "Iterative JSON parser with a standard Python iterator interface";
    homepage = "https://github.com/ICRAR/ijson";
    changelog = "https://github.com/ICRAR/ijson/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "editables";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MJYn2bXErcDmaNjG+nusG6fIxdQVwtJ/YPCB+OgNHeI=";
  };

  # Tests not included in archive.
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "editables" ];

  meta = {
    description = "Editable installations";
    homepage = "https://github.com/pfmoore/editables";
    changelog = "https://github.com/pfmoore/editables/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
  };
}

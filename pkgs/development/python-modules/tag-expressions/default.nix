{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tag-expressions";
  version = "2.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-EbSwfAH+sL3JGW+COfDA2f7cLGyKmQMsbyyDGy13Lkg=";
    pname = "tag_expressions";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "tagexpressions" ];

  meta = {
    description = "Package to parse logical tag expressions";
    homepage = "https://github.com/timofurrer/tag-expressions";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kalbasit ];
  };
}

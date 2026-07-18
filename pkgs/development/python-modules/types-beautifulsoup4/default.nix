{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  types-html5lib,
}:

buildPythonPackage rec {
  pname = "types-beautifulsoup4";
  version = "4.12.0.20250516";

  src = fetchPypi {
    inherit version;
    hash = "sha256-qhndc7M7cNYpat+S2oq4oMlFxQfm+31dtVNBXMd7QX4=";
    pname = "types_beautifulsoup4";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ types-html5lib ];
  pyproject = true;
  pythonImportsCheck = [ "bs4-stubs" ];

  meta = {
    description = "Typing stubs for beautifulsoup4";
    homepage = "https://pypi.org/project/types-beautifulsoup4/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}

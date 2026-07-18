{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyvex,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "ailment";
  version = "9.2.158";

  src = fetchFromGitHub {
    owner = "angr";
    repo = "ailment";
    tag = "v${version}";
    hash = "sha256-WnDtJaEpka6IhYOfOb2DZY0Hd8ghIn8mY5AuF/JktLg=";
  };

  # Tests depend on angr (possibly a circular dependency)
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pyvex
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "ailment" ];

  meta = {
    description = "Angr Intermediate Language";
    homepage = "https://github.com/angr/ailment";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}

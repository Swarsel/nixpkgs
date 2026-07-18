{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  setuptools,
}:

buildPythonPackage rec {
  pname = "qt-material";
  version = "2.17";

  src = fetchFromGitHub {
    owner = "dunderlab";
    repo = "qt-material";
    tag = "v${version}";
    hash = "sha256-ilrPA8SoVCo6FgwxWQ4sOjqURCFDQJLlTTkCZzTZQKI=";
  };

  build-system = [ setuptools ];
  dependencies = [ jinja2 ];
  pyproject = true;
  pythonImportsCheck = [ "qt_material" ];

  meta = {
    description = "Material inspired stylesheet for PySide2, PySide6, PyQt5 and PyQt6";
    homepage = "https://github.com/dunderlab/qt-material";
    changelog = "https://github.com/dunderlab/qt-material/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ _999eagle ];
  };
}

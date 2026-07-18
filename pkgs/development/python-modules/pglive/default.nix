{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  poetry-core,
  pyqt5,
  pyqt6,
  pyqtgraph,
  pyside6,
}:

buildPythonPackage rec {
  pname = "pglive";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "domarm-comat";
    repo = "pglive";
    tag = "v${version}";
    hash = "sha256-mdqQoWH1FF19vnXqDizKjU8zFwyCiUok4AyDaWbjEPk=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    pyqtgraph
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "pglive" ];

  pythonRelaxDeps = [
    "numpy"
    "pyqtgraph"
  ];

  passthru.optional-dependencies = {
    pyqt5 = [ pyqt5 ];
    pyqt6 = [ pyqt6 ];
    pyside6 = [ pyside6 ];
  };

  meta = {
    description = "Live plot for PyqtGraph";
    homepage = "https://github.com/domarm-comat/pglive";
    changelog = "https://github.com/domarm-comat/pglive/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fsagbuya ];
  };
}

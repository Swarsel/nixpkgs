{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  jinja2,
  lxml,
  mkdocs,
  poetry-core,
  requests,
}:

buildPythonPackage rec {
  pname = "mkdocs-drawio-file";
  version = "1.5.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5OPaG98m7ycxtEUyAYWunomHwq+r10VBnzza3kYtHhE=";
    pname = "mkdocs_drawio_file";
  };

  # No tests available
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    beautifulsoup4
    jinja2
    lxml
    mkdocs
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_drawio_file"
  ];

  pythonRelaxDeps = [
    "lxml"
  ];

  meta = {
    description = "Embedding files of Diagrams.net (Draw.io) into MkDocs";
    homepage = "https://github.com/onixpro/mkdocs-drawio-file/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

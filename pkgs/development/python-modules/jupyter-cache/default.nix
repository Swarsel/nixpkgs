{
  lib,
  attrs,
  buildPythonPackage,
  click,
  fetchPypi,
  flit-core,
  importlib-metadata,
  nbclient,
  nbformat,
  pyyaml,
  sqlalchemy,
  tabulate,
}:

buildPythonPackage rec {
  pname = "jupyter-cache";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FugI6xnj+2eiI9uQbhMepuAfA6on9JpyFM5qX+wYb7k=";
    pname = "jupyter_cache";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    attrs
    click
    importlib-metadata
    nbclient
    nbformat
    pyyaml
    sqlalchemy
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyter_cache" ];

  meta = {
    description = "Defined interface for working with a cache of jupyter notebooks";
    homepage = "https://github.com/executablebooks/jupyter-cache";
    changelog = "https://github.com/executablebooks/jupyter-cache/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "jcache";
  };
}

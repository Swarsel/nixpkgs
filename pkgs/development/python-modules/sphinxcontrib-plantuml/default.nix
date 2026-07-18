{
  lib,
  buildPythonPackage,
  fetchPypi,
  plantuml,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-plantuml";
  version = "0.31";

  src = fetchPypi {
    inherit version;
    hash = "sha256-/XR1L46gcOZBw/ikAvzPodSkBW4JZ7VgM9KnYoLZ+VY=";
    pname = "sphinxcontrib_plantuml";
  };

  propagatedBuildInputs = [ plantuml ];
  # No tests included.
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.plantuml" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Provides a Sphinx domain for embedding UML diagram with PlantUML";
    homepage = "https://github.com/sphinx-contrib/plantuml/";
    license = with lib.licenses; [ bsd2 ];
    maintainers = [ ];
  };
}

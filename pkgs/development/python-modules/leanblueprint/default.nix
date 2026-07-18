{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  gitpython,
  jinja2,
  # dependencies
  plasTeX,
  plastexdepgraph,
  plastexshowmore,
  rich,
  rich-click,
  # build-system
  setuptools,
  tomlkit,
}:
buildPythonPackage {
  pname = "leanblueprint";
  version = "0.0.20";

  src = fetchFromGitHub {
    owner = "PatrickMassot";
    repo = "leanblueprint";
    rev = "v0.0.20";
    hash = "sha256-jCNIf0pTO/7M4aLrbFyjGcTPmaIQnw32itKJdyCMn+g=";
  };

  build-system = [ setuptools ];

  dependencies = [
    plasTeX
    plastexshowmore
    plastexdepgraph
    click
    rich
    rich-click
    tomlkit
    jinja2
    gitpython
  ];

  pyproject = true;
  pythonImportsCheck = [ "leanblueprint" ];

  meta = {
    description = "This plasTeX plugin allowing to write blueprints for Lean 4 projects";
    homepage = "https://github.com/PatrickMassot/leanblueprint";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ niklashh ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  plasTeX,
  # dependencies
  pygraphviz,
  # build-system
  setuptools,
}:
buildPythonPackage {
  pname = "plastexdepgraph";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "PatrickMassot";
    repo = "plastexdepgraph";
    rev = "0.0.4";
    hash = "sha256-Q13uYYZe1QgZHS4Nj8ugr+Fmhva98ttJj3AlXTK6XDw=";
  };

  build-system = [ setuptools ];

  dependencies = [
    pygraphviz
    plasTeX
  ];

  pyproject = true;

  meta = {
    description = "PlasTeX plugin allowing to build dependency graphs";
    homepage = "https://github.com/PatrickMassot/plastexdepgraph";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ niklashh ];
  };
}

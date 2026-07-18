{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-jupyter-builder,
  hatchling,
  jupyter-collaboration,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyter-collaboration-ui";
  version = "2.4.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-DEoBl0qGRch6VDzubqIQ4480/G2Nz0G4pG/RMpr5fr4=";
    pname = "jupyter_collaboration_ui";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "jupyterlab>=4.0.0"' ""
  '';

  # no tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-jupyter-builder
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyter_collaboration_ui" ];
  passthru.tests = jupyter-collaboration;

  meta = {
    description = "JupyterLab/Jupyter Notebook 7+ extension providing user interface integration for real time collaboration";
    homepage = "https://github.com/jupyterlab/jupyter-collaboration/tree/main/projects/jupyter-collaboration-ui";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
})

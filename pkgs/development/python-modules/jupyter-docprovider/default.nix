{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-jupyter-builder,
  hatchling,
  jupyter-collaboration,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyter-docprovider";
  version = "2.4.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-DOMsS+96PQZfZ36D9lBlAq1oaD2PpzIBJaMWzviSx0s=";
    pname = "jupyter_docprovider";
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
  pythonImportsCheck = [ "jupyter_docprovider" ];
  passthru.tests = jupyter-collaboration;

  meta = {
    description = "JupyterLab/Jupyter Notebook 7+ extension integrating collaborative shared models";
    homepage = "https://github.com/jupyterlab/jupyter-collaboration/tree/main/projects/jupyter-docprovider";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
})

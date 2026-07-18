{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  # dependencies
  jsonschema,
  jupyter-collaboration,
  jupyter-events,
  jupyter-server,
  jupyter-server-fileid,
  jupyter-ydoc,
  pycrdt,
  pycrdt-websocket,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyter-server-ydoc";
  version = "2.4.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-dGMfR6Vdna333JGNeKCD/q7MbDavTS/N8mwO42v3A3I=";
    pname = "jupyter_server_ydoc";
  };

  # no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    jsonschema
    jupyter-events
    jupyter-server
    jupyter-server-fileid
    jupyter-ydoc
    pycrdt
    pycrdt-websocket
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyter_server_ydoc" ];
  passthru.tests = jupyter-collaboration;

  meta = {
    description = "Jupyter-server extension integrating collaborative shared models";
    homepage = "https://github.com/jupyterlab/jupyter-collaboration/tree/main/projects/jupyter-server-ydoc";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
})

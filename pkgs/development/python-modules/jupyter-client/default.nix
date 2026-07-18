{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  jupyter-core,
  python-dateutil,
  pyzmq,
  tornado,
  traitlets,
}:

buildPythonPackage rec {
  pname = "jupyter-client";
  version = "8.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-1VaBFBmk8tlshprzToVOPwWbfMLW0Bqc2chcJnaRvj4=";
    pname = "jupyter_client";
  };

  # Circular dependency with ipykernel
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    jupyter-core
    python-dateutil
    pyzmq
    tornado
    traitlets
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyter_client" ];

  meta = {
    description = "Jupyter protocol implementation and client libraries";
    homepage = "https://github.com/jupyter/jupyter_client";
    changelog = "https://github.com/jupyter/jupyter_client/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
}

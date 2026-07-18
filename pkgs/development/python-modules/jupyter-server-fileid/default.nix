{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  hatchling,
  jupyter-events,
  jupyter-server,
  pytest-jupyter,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "jupyter-server-fileid";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "jupyter-server";
    repo = "jupyter_server_fileid";
    tag = "v${version}";
    hash = "sha256-ob7hnqU7GdaDHEPF7+gwkmsboKZgiiLzzwxbBUwYHYo=";
  };

  checkInputs = [
    pytest-jupyter
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TEMPDIR
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    jupyter-events
    jupyter-server
  ];

  optional-dependencies = {
    cli = [ click ];
  };

  pyproject = true;
  pythonImportsCheck = [ "jupyter_server_fileid" ];

  meta = {
    description = "Extension that maintains file IDs for documents in a running Jupyter Server";
    homepage = "https://github.com/jupyter-server/jupyter_server_fileid";
    changelog = "https://github.com/jupyter-server/jupyter_server_fileid/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "jupyter-fileid";
  };
}

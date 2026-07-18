{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipykernel,
  # build inputs
  jupyter-client,
  nbconvert,
  nbformat,
  setuptools,
  # check inputs
  unittestCheckHook,
}:
let
  pname = "nbexec";
  version = "0.2.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "jsvine";
    repo = "nbexec";
    tag = "v${version}";
    hash = "sha256-Vv6EHX6WlnSmzQAYlO1mHnz5t078z3RQfVfte1+X2pw=";
  };

  # TODO there is a warning about debugpy_stream missing
  nativeCheckInputs = [
    unittestCheckHook
    ipykernel
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    jupyter-client
    nbformat
    nbconvert
  ];

  pyproject = true;
  pythonImportsCheck = [ "nbexec" ];

  unittestFlagsArray = [
    "-s"
    "test"
    "-v"
  ];

  meta = {
    description = "Dead-simple tool for executing Jupyter notebooks from the command line";
    homepage = "https://github.com/jsvine/nbexec";
    changelog = "https://github.com/jsvine/nbexec/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "nbexec";
  };
}

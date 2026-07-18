{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  ipykernel,
  ipywidgets,
  jupyter-client,
  jupyter-core,
  nbconvert,
  nbformat,
  pytest-asyncio,
  pytestCheckHook,
  testpath,
  traitlets,
  xmltodict,
}:

let
  nbclient = buildPythonPackage rec {
    pname = "nbclient";
    version = "0.10.4";

    src = fetchFromGitHub {
      owner = "jupyter";
      repo = "nbclient";
      tag = "v${version}";
      hash = "sha256-D7pgrNRrPT0fGOaHrNt3qeDXdbt1wJk5qfkQeLxsc7g=";
    };

    # circular dependencies if enabled by default
    doCheck = false;

    nativeCheckInputs = [
      ipykernel
      ipywidgets
      nbconvert
      pytest-asyncio
      pytestCheckHook
      testpath
      xmltodict
    ];

    preCheck = ''
      export HOME=$(mktemp -d)
    '';

    build-system = [ hatchling ];

    dependencies = [
      jupyter-client
      jupyter-core
      nbformat
      traitlets
    ];

    pyproject = true;

    passthru.tests = {
      check = nbclient.overridePythonAttrs (_: {
        doCheck = true;
      });
    };

    meta = {
      description = "Client library for executing notebooks";
      homepage = "https://github.com/jupyter/nbclient";
      license = lib.licenses.bsd3;
      maintainers = [ ];
      mainProgram = "jupyter-execute";
    };
  };
in
nbclient

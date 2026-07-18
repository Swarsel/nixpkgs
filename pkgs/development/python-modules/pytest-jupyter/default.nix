{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build
  hatchling,
  ipykernel,
  # optionals
  jupyter-client,
  # runtime
  jupyter-core,
  jupyter-server,
  nbformat,
  pytest,
  # tests
  pytest-timeout,
  pytestCheckHook,
}:

let
  self = buildPythonPackage rec {
    pname = "pytest-jupyter";
    version = "0.11.0";

    src = fetchFromGitHub {
      owner = "jupyter-server";
      repo = "pytest-jupyter";
      tag = "v${version}";
      hash = "sha256-x3Q9Ei4WIMDjjrYfWees30eooWep60EljGYyUyypxqQ=";
    };

    nativeBuildInputs = [ hatchling ];
    buildInputs = [ pytest ];
    propagatedBuildInputs = [ jupyter-core ];
    doCheck = false; # infinite recursion with jupyter-server

    nativeCheckInputs = [
      pytest-timeout
      pytestCheckHook
    ]
    ++ lib.concatAttrValues optional-dependencies;

    optional-dependencies = {
      client = [
        jupyter-client
        nbformat
        ipykernel
      ];

      server = [
        jupyter-server
        jupyter-client
        nbformat
        ipykernel
      ];
    };

    pyproject = true;

    passthru.tests = {
      check = self.overridePythonAttrs (_: {
        doCheck = false;
      });
    };

    meta = {
      description = "Pytest plugin for testing Jupyter core libraries and extensions";
      homepage = "https://github.com/jupyter-server/pytest-jupyter";
      changelog = "https://github.com/jupyter-server/pytest-jupyter/releases/tag/${src.tag}";
      license = lib.licenses.bsd3;
      maintainers = [ ];
    };
  };
in
self

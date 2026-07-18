{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build
  hatchling,
  # tests
  pytest-jupyter,
  pytest-timeout,
  pytestCheckHook,
  # runtime
  terminado,
}:

let
  self = buildPythonPackage rec {
    pname = "jupyter-server-terminals";
    version = "0.5.4";

    src = fetchFromGitHub {
      owner = "jupyter-server";
      repo = "jupyter_server_terminals";
      tag = "v${version}";
      hash = "sha256-gVR34Ajfv567isVmbP7Zx4AiptrdNqd032QxdMBpsTE=";
    };

    nativeBuildInputs = [ hatchling ];
    propagatedBuildInputs = [ terminado ];
    doCheck = false; # infinite recursion

    nativeCheckInputs = [
      pytest-jupyter
      pytest-timeout
      pytestCheckHook
    ]
    ++ pytest-jupyter.optional-dependencies.server;

    pyproject = true;

    passthru.tests = {
      check = self.overridePythonAttrs (_: {
        doCheck = true;
      });
    };

    meta = {
      description = "Jupyter Server Extension Providing Support for Terminals";
      homepage = "https://github.com/jupyter-server/jupyter_server_terminals";
      changelog = "https://github.com/jupyter-server/jupyter_server_terminals/releases/tag/${src.tag}";
      license = lib.licenses.bsd3;
      maintainers = [ ];
    };
  };
in
self

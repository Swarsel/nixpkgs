{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  ipython,
}:

buildPythonPackage rec {
  pname = "jupyter-ui-poll";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Kirill888";
    repo = "jupyter-ui-poll";
    tag = "v${version}";
    hash = "sha256-Q+y0Xr7wuo8ZwCHEELSi0QSXa8DLtfZ8XQc48eOk4bw=";
  };

  doCheck = false; # no tests in package :(
  build-system = [ flit-core ];
  dependencies = [ ipython ];
  pyproject = true;
  pythonImportsCheck = [ "jupyter_ui_poll" ];

  meta = {
    description = "Block jupyter cell execution while interacting with widgets";
    homepage = "https://github.com/Kirill888/jupyter-ui-poll";
    changelog = "https://github.com/Kirill888/jupyter-ui-poll/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}

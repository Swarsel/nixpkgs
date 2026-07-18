{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "plotext";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "piccolomo";
    repo = "plotext";
    tag = version;
    hash = "sha256-4cuStXnZFTlOoBp9w+LrTZavCWEaQdZMY4apGNKvBXE=";
  };

  # Package does not have a conventional test suite that can be run with either
  # `pytestCheckHook` or the standard setuptools testing situation.
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "plotext" ];

  meta = {
    description = "Plotting directly in the terminal";
    homepage = "https://github.com/piccolomo/plotext";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
    mainProgram = "plotext";
  };
}

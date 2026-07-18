{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flake8,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flake8-quotes";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "zheller";
    repo = "flake8-quotes";
    tag = version;
    hash = "sha256-A8PBdYQzOBpMYBQGchZouuZiZqmwhhjp2PJblnNZOFU=";
  };

  nativeCheckInputs = [
    flake8
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "flake8_quotes"
  ];

  meta = {
    description = "Flake8 extension for checking quotes in python";
    homepage = "https://github.com/zheller/flake8-quotes/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nim65s ];
  };
}

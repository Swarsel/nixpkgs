{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  crashtest,
  poetry-core,
  pytest-mock,
  pytestCheckHook,
  rapidfuzz,
}:

buildPythonPackage rec {
  pname = "cleo";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "python-poetry";
    repo = "cleo";
    tag = version;
    hash = "sha256-+OvE09hbF6McdXpXdv5UBdZ0LiSOTL8xyE/+bBNIFNk=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    crashtest
    rapidfuzz
  ];

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cleo"
    "cleo.application"
    "cleo.commands.command"
    "cleo.helpers"
  ];

  pythonRelaxDeps = [ "rapidfuzz" ];

  meta = {
    description = "Allows you to create beautiful and testable command-line interfaces";
    homepage = "https://github.com/python-poetry/cleo";
    changelog = "https://github.com/python-poetry/cleo/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jakewaksbaum ];
  };
}

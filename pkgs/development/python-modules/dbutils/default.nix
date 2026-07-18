{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dbutils";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "WebwareForPython";
    repo = "DBUtils";
    tag = "Release-${lib.replaceStrings [ "." ] [ "_" ] version}";
    hash = "sha256-YyZKGN7oNuCR4lU7pxkY+vLOWGQzQjqvAIOZc7LlvUM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "dbutils" ];

  meta = {
    description = "Database connections for multi-threaded environments";
    homepage = "https://webwareforpython.github.io/DBUtils/";
    changelog = "https://webwareforpython.github.io/DBUtils/changelog.html";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

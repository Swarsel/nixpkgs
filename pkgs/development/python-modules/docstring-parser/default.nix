{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "docstring-parser";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "rr-";
    repo = "docstring_parser";
    tag = version;
    hash = "sha256-hR+i1HU/ZpN6I3a8k/Wv2OrXgB4ls/A5OHZRqxEZS78=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "docstring_parser" ];

  meta = {
    description = "Parse Python docstrings in various flavors";
    homepage = "https://github.com/rr-/docstring_parser";
    changelog = "https://github.com/rr-/docstring_parser/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
  };
}

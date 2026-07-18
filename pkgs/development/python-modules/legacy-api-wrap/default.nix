{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-docstring-description,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "legacy-api-wrap";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "flying-sheep";
    repo = "legacy-api-wrap";
    tag = "v${version}";
    hash = "sha256-UvOkVNtH3MbD+ExF0dQ+XAfDx9v7YD3GCNUsEaH7zzM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-docstring-description
    hatch-vcs
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "legacy_api_wrap"
  ];

  meta = {
    description = "Wrap legacy APIs in python projects";
    homepage = "https://github.com/flying-sheep/legacy-api-wrap";
    changelog = "https://github.com/flying-sheep/legacy-api-wrap/releases/tag/${src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}

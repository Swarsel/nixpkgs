{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chardet,
  gitpython,
  hatchling,
  pygments,
  pytestCheckHook,
  rich,
}:

buildPythonPackage rec {
  pname = "pygount";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "roskakori";
    repo = "pygount";
    tag = "v${version}";
    hash = "sha256-1Ws/8znFusdn2jKFvbiPD7ZRbOnPDqBZceMizWfeVlM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    chardet
    gitpython
    pygments
    rich
  ];

  disabledTests = [
    # requires network access
    "test_can_find_files_from_mixed_cloned_git_remote_url_and_local"
    "test_can_extract_and_close_and_find_files_from_cloned_git_remote_url_with_revision"
    "test_succeeds_on_not_git_extension"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pygount" ];

  meta = {
    description = "Count lines of code for hundreds of languages using pygments";
    homepage = "https://github.com/roskakori/pygount";
    changelog = "https://github.com/roskakori/pygount/blob/${src.tag}/docs/changes.md";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "pygount";
  };
}

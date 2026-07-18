{
  lib,
  buildPythonPackage,
  fetchPypi,
  gitMinimal,
  hatchling,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "hatch-vcs";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-A5X6EmlANAIVCQw0Siv04qd7y+faqxb0Gze5jJWAn/k=";
    pname = "hatch_vcs";
  };

  nativeCheckInputs = [
    gitMinimal
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    hatchling
    setuptools-scm
  ];

  disabledTests = [
    # reacts to our setup-hook pretending a version
    "test_custom_tag_pattern_get_version"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hatch_vcs" ];

  meta = {
    description = "Plugin for Hatch that uses your preferred version control system (like Git) to determine project versions";
    homepage = "https://github.com/ofek/hatch-vcs";
    changelog = "https://github.com/ofek/hatch-vcs/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}

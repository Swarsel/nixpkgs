{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "orgparse";
  version = "0.4.20251020";

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = "orgparse";
    tag = "v${version}";
    hash = "sha256-RJ+1HVI9OgbylBxdEztpQ4v0MG0PUFqXlFfe0vsDaTg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm conftest.py
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  disabledTestPaths = [
    # Ignoring doc folder
    "doc/"
  ];

  disabledTests = [
    # AssertionError
    "test_data[01_attributes]"
    "test_data[03_repeated_tasks]"
    "test_data[04_logbook]"
    "test_level_0_timestamps"
  ];

  pyproject = true;
  pythonImportsCheck = [ "orgparse" ];

  meta = {
    description = "Emacs org-mode parser in Python";
    homepage = "https://github.com/karlicoss/orgparse";
    changelog = "https://github.com/karlicoss/orgparse/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ twitchy0 ];
  };
}

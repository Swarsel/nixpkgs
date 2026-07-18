{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  mkdocs-material,
  pytest-click,
  pytest-timeout,
  pytestCheckHook,
  selectolax,
}:

buildPythonPackage rec {
  pname = "mkdocs-glightbox";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "blueswen";
    repo = "mkdocs-glightbox";
    tag = "v${version}";
    hash = "sha256-6HkBeZHBLR3HqWh3WjjCqxR85nQuQqq9+7UwbXOZHRk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-click
    pytest-timeout
    mkdocs-material
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    selectolax
  ];

  disabledTestPaths = [
    # dont execute benchmarks on hydra
    "tests/test_perf.py"
  ];

  disabledTests = [
    # Checks compatible with material privacy plugin, which is currently not packaged in nixpkgs.
    "privacy"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_glightbox"
  ];

  meta = {
    description = "MkDocs plugin supports image lightbox (zoom effect) with GLightbox";
    homepage = "https://github.com/blueswen/mkdocs-glightbox";
    changelog = "https://github.com/blueswen/mkdocs-glightbox/blob/v${version}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcel ];
  };
}

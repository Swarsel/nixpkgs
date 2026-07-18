{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hatch-docstring-description";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "flying-sheep";
    repo = "hatch-docstring-description";
    tag = "v${version}";
    hash = "sha256-ouor0FV3qdXYJx5EWFUWSKp8Cc/EuD1WXrtLvbYG+XI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  disabledTests = [
    # See https://github.com/flying-sheep/hatch-docstring-description/issues/107
    "test_e2e[.]"
    "test_e2e[src]"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hatch_docstring_description" ];

  meta = {
    description = "Derive PyPI package description from Python package docstring";
    homepage = "https://github.com/flying-sheep/hatch-docstring-description";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      samuela
    ];
  };
}

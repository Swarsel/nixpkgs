{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pip,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "argparse-manpage";
  version = "4.7";

  src = fetchFromGitHub {
    owner = "praiskup";
    repo = "argparse-manpage";
    tag = "v${version}";
    hash = "sha256-nonC0oK3T/8+gSa0lRaCf2wvvXoRBPP8b1jioNmW4qI=";
  };

  nativeBuildInputs = [
    setuptools
    packaging
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pip
  ];

  disabledTestPaths = [
    # network access to install setuptools, likely due to pip update
    "tests/test_examples.py"
  ];

  disabledTests = [
    # TypeError: dist must be a Distribution instance
    "test_old_example"
    "test_old_example_file_name"
  ];

  optional-dependencies = {
    setuptools = [ setuptools ];
  };

  pyproject = true;
  pythonImportsCheck = [ "argparse_manpage" ];

  meta = {
    description = "Automatically build man-pages for your Python project";
    homepage = "https://github.com/praiskup/argparse-manpage";
    changelog = "https://github.com/praiskup/argparse-manpage/blob/${src.tag}/NEWS";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "argparse-manpage";
  };
}

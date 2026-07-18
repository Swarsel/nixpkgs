{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  compressed-rtf,
  pytest-console-scripts,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tnefparse";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "koodaamo";
    repo = "tnefparse";
    tag = version;
    hash = "sha256-t2ouuuy6fzwb6SZNpxeGSleL/11SgTT8Ce28/ST1glw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-console-scripts

    # tests always require this.
    compressed-rtf
  ];

  build-system = [ setuptools ];

  disabledTests = [
    # ensures there's a "optional argument" in the CLI usage, and its output has changed since.
    "test_help_is_printed"
  ];

  optional-dependencies = {
    compressed-rtf = [ compressed-rtf ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tnefparse" ];

  meta = {
    description = "TNEF decoding library written in python, without external dependencies";
    homepage = "https://github.com/koodaamo/tnefparse";
    changelog = "https://github.com/koodaamo/tnefparse/releases/tag/${version}";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      flokli
    ];
  };
}

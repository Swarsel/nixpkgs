{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  flake8,
  hypothesis,
  hypothesmith,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flake8-bugbear";
  version = "25.11.29";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "flake8-bugbear";
    tag = version;
    hash = "sha256-aIcLCUUiXVzt9aDllXmm0TqIDxwTa3zcs6Yc2H5LnWY=";
  };

  nativeCheckInputs = [
    flake8
    pytestCheckHook
    hypothesis
    hypothesmith
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    flake8
  ];

  pyproject = true;
  pythonImportsCheck = [ "bugbear" ];

  meta = {
    description = "Plugin for Flake8 to find bugs and design problems";

    longDescription = ''
      A plugin for flake8 finding likely bugs and design problems in your
      program.
    '';

    homepage = "https://github.com/PyCQA/flake8-bugbear";
    changelog = "https://github.com/PyCQA/flake8-bugbear/blob/${src.tag}/README.rst#change-log";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ newam ];
  };
}

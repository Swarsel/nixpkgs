{
  lib,
  fetchFromGitHub,
  # dependencies
  baron,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "redbaron";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "redbaron";
    tag = finalAttrs.version;
    hash = "sha256-Wgq7ltAsy4aPtfEiLp42p5pfcc/w9U0kFJTVNqy0iio=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    cd tests
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    baron
  ];

  disabledTestPaths = [
    "test_bounding_box.py"
  ];

  disabledTests = [
    # AssertionError: assert '0 ----------...39m\x1b[39m\n' == '0 ----------...5m]\x1b[39m\n'
    "test_highlight"
  ];

  pyproject = true;

  meta = {
    description = "Abstraction on top of baron, a FST for python to make writing refactoring code a realistic task";
    homepage = "https://redbaron.readthedocs.io/en/latest";
    changelog = "https://github.com/PyCQA/redbaron/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
    downloadPage = "https://github.com/PyCQA/redbaron";
  };
})

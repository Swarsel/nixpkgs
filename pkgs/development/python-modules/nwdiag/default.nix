{
  lib,
  fetchFromGitHub,
  blockdiag,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nwdiag";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "blockdiag";
    repo = "nwdiag";
    tag = version;
    hash = "sha256-uKrdkXpL5YBr953sRsHknYg+2/WwrZmyDf8BMA2+0tU=";
  };

  patches = [ ./fix_test_generate.patch ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ blockdiag ];

  disabledTests = [
    # AttributeError: 'TestRstDirectives' object has no attribute 'assertRegexpMatches'
    "svg"
    "noviewbox"
  ];

  enabledTestPaths = [ "src/nwdiag/tests/" ];
  pyproject = true;
  pythonImportsCheck = [ "nwdiag" ];

  meta = {
    description = "Generate network-diagram image from spec-text file (similar to Graphviz)";
    homepage = "http://blockdiag.com/";
    changelog = "https://github.com/blockdiag/nwdiag/blob/${version}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.unix;
    mainProgram = "rackdiag";
  };
}

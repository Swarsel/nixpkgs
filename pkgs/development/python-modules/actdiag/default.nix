{
  lib,
  fetchFromGitHub,
  blockdiag,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "actdiag";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "blockdiag";
    repo = "actdiag";
    tag = version;
    hash = "sha256-WmprkHOgvlsOIg8H77P7fzEqxGnj6xaL7Df7urRkg3o=";
  };

  patches = [ ./fix_test_generate.patch ];
  propagatedBuildInputs = [ blockdiag ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # AttributeError: 'TestRstDirectives' object has no attribute 'assertRegexpMatches'
    "svg"
    "noviewbox"
  ];

  enabledTestPaths = [ "src/actdiag/tests/" ];
  pyproject = true;
  pythonImportsCheck = [ "actdiag" ];

  meta = {
    description = "Generate activity-diagram image from spec-text file (similar to Graphviz)";
    homepage = "http://blockdiag.com/";
    changelog = "https://github.com/blockdiag/actdiag/blob/${version}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.unix;
    mainProgram = "actdiag";
  };
}

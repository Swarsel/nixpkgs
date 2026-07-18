{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  pytest-icdiff,
  pytestCheckHook,
  pyyaml,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "symbex";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "symbex";
    tag = version;
    hash = "sha256-swg98z4DpQJ5rq7tdsd3FofbYF7O5S+9ZR0weoM2DoI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
    pytest-icdiff
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ click ];

  disabledTests = [
    # Fails with `TypeError: CliRunner.__init__() got an unexpected keyword argument 'mix_std...`
    # https://github.com/simonw/symbex/issues/48
    "test_errors"
    # Fails with AssertionError (SystemExit(1).stdout is '' not the expected message)
    "test_output"
  ];

  pyproject = true;
  pythonImportsCheck = [ "symbex" ];

  meta = {
    description = "Find the Python code for specified symbols";
    homepage = "https://github.com/simonw/symbex";
    changelog = "https://github.com/simonw/symbex/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}

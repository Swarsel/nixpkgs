{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  # build-system
  hatchling,
  # dependencies
  param,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyct";
  version = "0.6.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-1OUTss81thZWBa5fzl8qSZhbxnRzxXnehRNLjHHTdKg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    param
    pyyaml
    requests
  ];

  # Only the command line doesn't work on with Python 3.12, due to usage of
  # deprecated distutils module. Not disabling it totally.
  disabledTestPaths = lib.optionals (pythonAtLeast "3.12") [
    "pyct/tests/test_cmd.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyct" ];

  meta = {
    description = "ClI for Python common tasks for users";
    homepage = "https://github.com/pyviz/pyct";
    changelog = "https://github.com/pyviz-dev/pyct/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "pyct";
  };
})

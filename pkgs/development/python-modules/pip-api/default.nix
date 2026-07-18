{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pip,
  pretend,
  pytestCheckHook,
  setuptools,
  virtualenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "pip-api";
  version = "0.0.34";

  src = fetchFromGitHub {
    owner = "di";
    repo = "pip-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nmCP4hp+BsD80OBjerOu+QTBBExGHvn/v19od4V3ncI=";
  };

  nativeCheckInputs = [
    pretend
    pytestCheckHook
    virtualenv
  ];

  build-system = [ setuptools ];
  dependencies = [ pip ];

  disabledTests = [
    "test_hash"
    "test_hash_default_algorithm_is_256"
    "test_installed_distributions"
    "test_invoke_install"
    "test_invoke_uninstall"
    "test_isolation"
    # Tests fails on hydra
    "test_parse_requirements_editable"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pip_api" ];

  meta = {
    description = "Importable pip API";
    homepage = "https://github.com/di/pip-api/";
    changelog = "https://github.com/di/pip-api/blob/${finalAttrs.src.tag}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

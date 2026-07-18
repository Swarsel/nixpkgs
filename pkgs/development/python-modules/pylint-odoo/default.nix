{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pylint-plugin-utils,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "pylint-odoo";
  version = "10.0.7";

  src = fetchFromGitHub {
    owner = "OCA";
    repo = "pylint-odoo";
    tag = "v${version}";
    hash = "sha256-xwtIaZTQcS/Q96r3nLeIT3e8B5Z4zpipA56GwIIBLLA=";
  };

  env.BUILD_README = true; # Enables more tests
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pylint-plugin-utils
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylint_odoo" ];

  pythonRelaxDeps = [
    "pylint-plugin-utils"
    "pylint"
  ];

  meta = {
    description = "Odoo plugin for Pylint";
    homepage = "https://github.com/OCA/pylint-odoo";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ yajo ];
  };
}

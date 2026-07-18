{
  lib,
  fetchFromGitHub,
  argcomplete,
  buildPythonPackage,
  colcon,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "colcon-argcomplete";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-argcomplete";
    tag = version;
    hash = "sha256-A6ia9OVZa+DwChVwCmkjvDtUloiFQyqtmhlaApbD7iI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    argcomplete
  ];

  disabledTestPaths = [
    "test/test_flake8.py"
    "test/test_spell_check.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_argcomplete"
  ];

  meta = {
    description = "Extension for colcon-core to provide command line completion using argcomplete";
    homepage = "https://github.com/colcon/colcon-argcomplete";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}

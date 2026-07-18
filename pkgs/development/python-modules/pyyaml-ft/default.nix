{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libyaml,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyyaml-ft";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "Quansight-Labs";
    repo = "pyyaml-ft";
    tag = "v${version}";
    hash = "sha256-GiXYpcAccKgROw144eOPY0gS0xW+3K/jRUl+JnBEaO8=";
  };

  buildInputs = [ libyaml ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    setuptools
  ];

  disabled = pythonOlder "3.13";
  pyproject = true;
  pythonImportsCheck = [ "yaml_ft" ];

  meta = {
    description = "YAML parser and emitter for Python with support for free-threading";
    homepage = "https://github.com/Quansight-Labs/pyyaml-ft";
    changelog = "https://github.com/Quansight-Labs/pyyaml-ft/blob/${src.tag}/CHANGES";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

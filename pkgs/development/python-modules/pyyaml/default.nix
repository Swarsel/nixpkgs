{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libyaml,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyyaml";
  version = "6.0.3";

  src = fetchFromGitHub {
    owner = "yaml";
    repo = "pyyaml";
    tag = version;
    hash = "sha256-jUooIBp80cLxvdU/zLF0X8Yjrf0Yp9peYeiFjuV8AHA=";
  };

  buildInputs = [ libyaml ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "yaml" ];

  meta = {
    description = "Next generation YAML parser and emitter for Python";
    homepage = "https://github.com/yaml/pyyaml";
    changelog = "https://github.com/yaml/pyyaml/blob/${src.rev}/CHANGES";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

{
  lib,
  fetchFromGitHub,
  arrow,
  buildPythonPackage,
  cloudpickle,
  construct,
  cryptography,
  numpy,
  pytestCheckHook,
  pythonAtLeast,
  ruamel-yaml,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "construct-typing";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "timrid";
    repo = "construct-typing";
    tag = "v${version}";
    hash = "sha256-iiMnt/f1ppciL6AVq3q0wOtoARcNYJycQA5Ev+dIow8=";
  };

  nativeCheckInputs = [
    arrow
    cloudpickle
    cryptography
    numpy
    pytestCheckHook
    ruamel-yaml
  ];

  build-system = [ setuptools ];

  dependencies = [
    construct
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "construct-stubs"
    "construct_typed"
  ];

  pythonRelaxDeps = [ "construct" ];

  meta = {
    description = "Extension for the python package 'construct' that adds typing features";
    homepage = "https://github.com/timrid/construct-typing";
    changelog = "https://github.com/timrid/construct-typing/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

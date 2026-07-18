{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "jmespath";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jmespath";
    repo = "jmespath.py";
    tag = finalAttrs.version;
    hash = "sha256-DtRMWKE1LeD+NAmMJOISfBo5w9HJW7XFeQp7A3NjkjE=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  enabledTestPaths = [
    "tests"
  ];

  pyproject = true;

  meta = {
    description = "JMESPath allows you to declaratively specify how to extract elements from a JSON document";
    homepage = "https://github.com/jmespath/jmespath.py";
    changelog = "https://github.com/jmespath/jmespath.py/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "jp.py";
  };
})

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pydantic,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "packageurl-python";
  version = "0.17.6";

  src = fetchFromGitHub {
    owner = "package-url";
    repo = "packageurl-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jH4zJN3XGPFBnto26pcvADXogpooj3dqpqkWnKXgICY=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pydantic
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "packageurl" ];

  meta = {
    description = "Python parser and builder for package URLs";
    homepage = "https://github.com/package-url/packageurl-python";
    changelog = "https://github.com/package-url/packageurl-python/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ armijnhemel ];
  };
})

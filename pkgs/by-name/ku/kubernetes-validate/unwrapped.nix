{
  lib,
  buildPythonPackage,
  fetchPypi,
  importlib-resources,
  jsonschema,
  packaging,
  pytestCheckHook,
  pyyaml,
  referencing,
  setuptools,
  typing-extensions,
  versionCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "kubernetes-validate";
  version = "1.36.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7b/S256ItXECmqFqsRFsZQKtK5YotnON051jkyP4RxU=";
    pname = "kubernetes_validate";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    importlib-resources
    jsonschema
    packaging
    pyyaml
    referencing
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "kubernetes_validate" ];

  meta = {
    description = "Module to validate Kubernetes resource definitions against the declared Kubernetes schemas";
    homepage = "https://github.com/willthames/kubernetes-validate";
    changelog = "https://github.com/willthames/kubernetes-validate/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lykos153 ];
    mainProgram = "kubernetes-validate";
  };
})

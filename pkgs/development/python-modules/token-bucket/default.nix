{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "token-bucket";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "falconry";
    repo = "token-bucket";
    tag = finalAttrs.version;
    hash = "sha256-ZWmrLZ3CsotGAoVdbVTz7YNrBHfCKR5t94wrdVMM3P4=";
  };

  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Token Bucket Implementation for Python Web Apps";
    homepage = "https://github.com/falconry/token-bucket";
    changelog = "https://github.com/falconry/token-bucket/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})

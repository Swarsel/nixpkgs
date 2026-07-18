{
  lib,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  certvalidator,
  mscerts,
  oscrypto,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "signify";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "ralphje";
    repo = "signify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ICmBzIbkynxRNojNQrQZoydMyFd6j3F1BLWN8VeB5dE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    asn1crypto
    certvalidator
    mscerts
    oscrypto
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "signify" ];

  meta = {
    description = "Library that verifies PE Authenticode-signed binaries";
    homepage = "https://github.com/ralphje/signify";
    changelog = "https://github.com/ralphje/signify/blob/refs/tags/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ baloo ];
  };
})

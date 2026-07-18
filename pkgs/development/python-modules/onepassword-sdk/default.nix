{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pydantic,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "onepassword-sdk";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "1Password";
    repo = "onepassword-sdk-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mMmHC5zBY1w+Y+NAZJkP7m1CqErwCv2bMNAo1TTNm6E=";
  };

  # Tests require a live 1Password service account token.
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "onepassword" ];

  meta = {
    description = "1Password Python SDK for programmatic secret management";
    homepage = "https://github.com/1Password/onepassword-sdk-python";
    changelog = "https://github.com/1Password/onepassword-sdk-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mahyarmirrashed ];
  };
})

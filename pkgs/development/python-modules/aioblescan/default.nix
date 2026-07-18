{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioblescan";
  version = "0.2.14";

  src = fetchFromGitHub {
    owner = "frawau";
    repo = "aioblescan";
    tag = finalAttrs.version;
    hash = "sha256-JeA9jX566OSRiejdnlifbcNGm0J0C+xzA6zXDUyZ6jc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "aioblescan" ];

  meta = {
    description = "Library to listen for BLE advertized packets";
    homepage = "https://github.com/frawau/aioblescan";
    changelog = "https://github.com/frawau/aioblescan/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "aioblescan";
  };
})

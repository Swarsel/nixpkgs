{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "apykuma";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "PerchunPak";
    repo = "apykuma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Dxlyi0syoq+sfgjMLWHhpeKhDFgpfQrp18DJeBjrAEg=";
  };

  # has no tests
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;

  pythonImportsCheck = [
    "apykuma"
  ];

  meta = {
    description = "Small library to notify Uptime Kuma that the service is up";
    homepage = "https://github.com/PerchunPak/apykuma";
    changelog = "https://github.com/PerchunPak/apykuma/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ PerchunPak ];
  };
})

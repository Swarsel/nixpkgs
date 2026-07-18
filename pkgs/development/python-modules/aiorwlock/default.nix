{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiorwlock";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiorwlock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+favszX1mVuuLWqKCIk+i5frX+y2kOArAUVIAJG1otY=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "aiorwlock" ];

  meta = {
    description = "Read write lock for asyncio";
    homepage = "https://github.com/aio-libs/aiorwlock";
    changelog = "https://github.com/aio-libs/aiorwlock/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ billhuang ];
  };
})

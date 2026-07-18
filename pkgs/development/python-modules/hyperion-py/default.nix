{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio_0,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "hyperion-py";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "dermotduffy";
    repo = "hyperion-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-14taFSrtmgTBiie0eY2fSRkZndJSZ4GJNRx3MonrTzs=";
  };

  nativeCheckInputs = [
    pytest-asyncio_0
    (pytest-aiohttp.override { pytest-asyncio = pytest-asyncio_0; })
    pytest-cov-stub
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "hyperion" ];

  meta = {
    description = "Python package for Hyperion Ambient Lighting";
    homepage = "https://github.com/dermotduffy/hyperion-py";
    changelog = "https://github.com/dermotduffy/hyperion-py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiopulsegrow";
  version = "25.12.6";

  src = fetchFromGitHub {
    owner = "pvizeli";
    repo = "aiopulsegrow";
    tag = finalAttrs.version;
    hash = "sha256-Srtk8EmvTQvx2//TuB2JR74lw58EdLORKWDnvTPStww=";
  };

  nativeCheckInputs = [
    aioresponses
    pytestCheckHook
    pytest-aiohttp
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aiopulsegrow" ];

  meta = {
    description = "Python async api client for Pulse Grow";
    homepage = "https://github.com/pvizeli/aiopulsegrow";
    changelog = "https://github.com/pvizeli/aiopulsegrow/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

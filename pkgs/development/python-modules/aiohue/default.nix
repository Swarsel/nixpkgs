{
  lib,
  fetchFromGitHub,
  aiohttp,
  asyncio-throttle,
  awesomeversion,
  buildPythonPackage,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiohue";
  version = "4.8.1";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "aiohue";
    tag = finalAttrs.version;
    hash = "sha256-Ex1ofLnpoO2oVQ3bc0Fy1kaSd1JGoL8DmnOgFRwz3D8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-aiohttp
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    awesomeversion
    aiohttp
    asyncio-throttle
  ];

  disabledTestPaths = [
    # File are prefixed with test_
    "examples/"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aiohue"
    "aiohue.discovery"
  ];

  meta = {
    description = "Python package to talk to Philips Hue";
    homepage = "https://github.com/home-assistant-libs/aiohue";
    changelog = "https://github.com/home-assistant-libs/aiohue/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

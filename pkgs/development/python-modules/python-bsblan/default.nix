{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  hatchling,
  packaging,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  python-backoff,
  yarl,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-bsblan";
  version = "6.1.6";

  src = fetchFromGitHub {
    owner = "liudger";
    repo = "python-bsblan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1nq1m1jGks4YPn64pUz8lKlES2PwvdfsMlRFYiAEbYg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytest-xdist
    pytestCheckHook
    zeroconf
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    packaging
    pydantic
    python-backoff
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "bsblan" ];
  pythonRelaxDeps = [ "async-timeout" ];

  meta = {
    description = "Module to control and monitor an BSBLan device programmatically";
    homepage = "https://github.com/liudger/python-bsblan";
    changelog = "https://github.com/liudger/python-bsblan/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

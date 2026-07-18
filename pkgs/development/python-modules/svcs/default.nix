{
  lib,
  stdenv,
  fetchFromGitHub,
  # test dependencies
  aiohttp,
  attrs,
  buildPythonPackage,
  fastapi,
  flask,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  httpx,
  pyramid,
  pytest-asyncio,
  pytestCheckHook,
  starlette,
  sybil,
}:

buildPythonPackage rec {
  pname = "svcs";
  version = "25.1.0";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "svcs";
    tag = version;
    hash = "sha256-dDPmOKGifAGmAH3TD0NzJvR8lUB5qDWbxIwzHtNeF+4=";
  };

  nativeCheckInputs = [
    aiohttp
    fastapi
    flask
    httpx
    pyramid
    pytest-asyncio
    pytestCheckHook
    starlette
    sybil
  ];

  build-system = [
    hatch-fancy-pypi-readme
    hatch-vcs
    hatchling
  ];

  dependencies = [
    attrs
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "test_aclose_registry_ok"
    "test_registrations"
    "test_get_pings"
    "test_client_pool_register_value"
  ];

  pyproject = true;
  pythonImportsCheck = [ "svcs" ];

  meta = {
    description = "Flexible Service Locator for Python";
    homepage = "https://github.com/hynek/svcs";
    changelog = "https://github.com/hynek/svcs/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ taranarmo ];
  };
}

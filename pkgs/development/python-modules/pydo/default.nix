{
  lib,
  fetchFromGitHub,
  # tests
  aioresponses,
  # dependencies
  azure-core,
  azure-identity,
  buildPythonPackage,
  isodate,
  msrest,
  # build-system
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  responses,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydo";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = "digitalocean";
    repo = "pydo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wo1qg8mromlI+DsYns0IYtCwsYQgLisSSpkHPtnoR/E=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
    responses
  ];

  build-system = [ poetry-core ];

  dependencies = [
    azure-core
    azure-identity
    isodate
    msrest
  ];

  # integration tests require hitting the live api with a
  # digital ocean token
  disabledTestPaths = [
    "tests/integration/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydo" ];

  meta = {
    description = "Official DigitalOcean Client based on the DO OpenAPIv3 specification";
    homepage = "https://github.com/digitalocean/pydo";
    changelog = "https://github.com/digitalocean/pydo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  devtools,
  fastapi,
  httpx2,
  # build-system
  poetry-core,
  # dependencies
  prometheus-client,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  starlette,
}:

buildPythonPackage (finalAttrs: {
  pname = "prometheus-fastapi-instrumentator";
  version = "8.0.2";

  src = fetchFromGitHub {
    owner = "trallnag";
    repo = "prometheus-fastapi-instrumentator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fTJjAM1jUZXfhjLo9xqlu45LaoqZ330ogOA6x7aByqw=";
  };

  # numerous test failures on Darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    devtools
    fastapi
    httpx2
    pytest-asyncio
    pytestCheckHook
    requests
  ];

  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    prometheus-client
    starlette
  ];

  # TODO: Cleanup when https://github.com/NixOS/nixpkgs/pull/538958 reaches
  # `master`...
  disabledTests = lib.optionals (lib.versionOlder fastapi.version "0.137") [
    # Asserts that instrumentation works with fastapi 0.137+,
    # fails on nixpkgs with fastapi 0.136.
    "test_mount_inside_included_router_resolves_path"
  ];

  pyproject = true;
  pythonImportsCheck = [ "prometheus_fastapi_instrumentator" ];

  meta = {
    description = "Instrument FastAPI with Prometheus metrics";
    homepage = "https://github.com/trallnag/prometheus-fastapi-instrumentator";
    changelog = "https://github.com/trallnag/prometheus-fastapi-instrumentator/blob/${finalAttrs.src.tag}/CHANGELOG.md";

    license = with lib.licenses; [
      isc
      bsd3
    ];

    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
})

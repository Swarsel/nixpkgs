{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  redis,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "burner-redis";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "prefectlabs";
    repo = "burner-redis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ybi8F0imJKUQiF0Gfy/WGcAqfQSPoT1tAvOXDnI5Z7M=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  doCheck = true;

  nativeCheckInputs = [
    pytestCheckHook

    pytest-asyncio
    redis
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-laD/FhYxXCOZOvs0e7ad80vUgX4eoHpLQu6dx/glkEM=";
  };

  pyproject = true;
  pythonImportsCheck = [ "burner_redis" ];

  meta = {
    description = "Embedded, in-process Redis-compatible database";
    homepage = "https://github.com/prefectlabs/burner-redis";
    changelog = "https://github.com/prefectlabs/burner-redis/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    downloadPage = "https://github.com/prefectlabs/burner-redis/releases";
  };
})

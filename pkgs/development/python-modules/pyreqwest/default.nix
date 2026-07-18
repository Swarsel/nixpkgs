{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cacert,
  dirty-equals,
  docker,
  granian,
  httpx,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  requests-toolbelt,
  rustPlatform,
  starlette,
  syrupy,
  trustme,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyreqwest";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "MarkusSintonen";
    repo = "pyreqwest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o33/KkPBl4ActDV0R8KqWll6F47HPO3amHFI00rHryE=";
  };

  nativeCheckInputs = [
    cacert
    dirty-equals
    docker
    granian
    httpx
    pydantic
    pytest-asyncio
    pytestCheckHook
    requests-toolbelt
    starlette
    syrupy
    trustme
    yarl
  ];

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-+flEikEImbiu/x+pJQz3rynYKmfjaS9N0/A1HSzH0jU=";
  };

  disabledTestPaths = [
    # requires a running Docker daemon
    "tests/test_examples.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyreqwest" ];

  meta = {
    description = "Fast Python HTTP client based on Rust reqwest";
    homepage = "https://github.com/MarkusSintonen/pyreqwest";
    changelog = "https://github.com/MarkusSintonen/pyreqwest/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})

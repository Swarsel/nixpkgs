{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # test dependencies
  dirty-equals,
  # runtime dependencies
  fastapi,
  hatchling,
  httpx,
  inline-snapshot,
  issubclass,
  jinja2,
  pydantic,
  pydantic-settings,
  pytest-fixture-classes,
  pytestCheckHook,
  python-multipart,
  pythonAtLeast,
  starlette,
  svcs,
  typer,
  typing-extensions,
  typing-inspection,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "cadwyn";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "zmievsa";
    repo = "cadwyn";
    tag = finalAttrs.version;
    hash = "sha256-UI5gD4WXzn3a/7SDNKGvfGLRteMmCD/yHMEoXZ8By+A=";
  };

  nativeCheckInputs = [
    dirty-equals
    httpx
    inline-snapshot
    pydantic-settings
    pytest-fixture-classes
    pytestCheckHook
    python-multipart
    svcs
    typer
    uvicorn
  ];

  build-system = [ hatchling ];

  dependencies = [
    fastapi
    issubclass
    jinja2
    pydantic
    starlette
    typing-extensions
    typing-inspection
  ];

  pyproject = true;
  pythonImportsCheck = [ "cadwyn" ];

  meta = {
    description = "Production-ready community-driven modern Stripe-like API versioning in FastAPI";
    homepage = "https://github.com/zmievsa/cadwyn";
    changelog = "https://github.com/zmievsa/cadwyn/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ taranarmo ];
  };
})

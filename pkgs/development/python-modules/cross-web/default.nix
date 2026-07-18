{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  chalice,
  django,
  fastapi,
  flask,
  hatchling,
  httpx,
  litestar,
  pytest-asyncio,
  pytest-django,
  pytestCheckHook,
  python-multipart,
  quart,
  sanic,
  sanic-testing,
  starlette,
  typing-extensions,
  werkzeug,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "cross-web";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "usecross";
    repo = "cross-web";
    rev = finalAttrs.version;
    hash = "sha256-JxwzTU17jCQMFNCtmcZVAZQnwDZjHNxCGNdKhkCMoPs=";
  };

  env.DJANGO_SETTINGS_MODULE = "testing._django_settings";

  nativeCheckInputs = [
    pytest-asyncio
    pytest-django
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    export PYTHONPATH="$PYTHONPATH:$PWD/tests"
  '';

  build-system = [ hatchling ];
  dependencies = [ typing-extensions ];

  optional-dependencies = {
    integrations = [
      fastapi
      httpx
      python-multipart
      starlette
      django
      flask
      werkzeug
      sanic
      aiohttp
      yarl
      quart
      chalice
      litestar
      sanic-testing
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cross_web" ];

  meta = {
    description = "Universal web framework adapter for Python";
    homepage = "https://github.com/usecross/cross-web";
    changelog = "https://github.com/usecross/cross-web/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})

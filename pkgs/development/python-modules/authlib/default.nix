{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cachelib,
  cryptography,
  flask,
  flask-sqlalchemy,
  httpx,
  joserfc,
  mock,
  pytest-asyncio,
  pytestCheckHook,
  python-multipart,
  requests,
  setuptools,
  starlette,
  werkzeug,
}:

buildPythonPackage (finalAttrs: {
  pname = "authlib";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "lepture";
    repo = "authlib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FLSe9piZoFlOAutzoMcgygbsJsR8uSlZWqdNBU6D+aE=";
  };

  nativeCheckInputs = [
    cachelib
    flask
    flask-sqlalchemy
    httpx
    mock
    pytest-asyncio
    pytestCheckHook
    python-multipart
    requests
    starlette
    werkzeug
  ];

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    joserfc
  ];

  disabledTestPaths = [
    # Django tests require a running instance
    "tests/django/"
    "tests/clients/test_django/"
    # Unsupported encryption algorithm
    "tests/jose/test_chacha20.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "authlib" ];

  meta = {
    description = "Library for building OAuth and OpenID Connect servers";
    homepage = "https://github.com/lepture/authlib";
    changelog = "https://github.com/lepture/authlib/blob/${finalAttrs.src.tag}/docs/upgrades/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ flokli ];
  };
})

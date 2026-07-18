{
  lib,
  stdenv,
  fetchFromGitHub,
  asgiref,
  autobahn,
  buildPythonPackage,
  django,
  hypothesis,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  twisted,
}:

buildPythonPackage (finalAttrs: {
  pname = "daphne";
  version = "4.2.2";

  src = fetchFromGitHub {
    owner = "django";
    repo = "daphne";
    tag = finalAttrs.version;
    hash = "sha256-i0BwZCpMZW6WXK94FSvlEheXHUzXviCBEew6AbkLkpk=";
  };

  # Most tests fail on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    django
    hypothesis
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    asgiref
    autobahn
    twisted
  ]
  ++ twisted.optional-dependencies.tls;

  pyproject = true;
  pythonImportsCheck = [ "daphne" ];

  meta = {
    description = "Django ASGI (HTTP/WebSocket) server";
    homepage = "https://github.com/django/daphne";
    changelog = "https://github.com/django/daphne/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "daphne";
  };
})

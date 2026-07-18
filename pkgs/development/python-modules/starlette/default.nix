{
  lib,
  fetchFromGitHub,
  # dependencies
  anyio,
  buildPythonPackage,
  # reverse dependencies
  fastapi,
  # build-system
  hatchling,
  httpx,
  # optional dependencies
  itsdangerous,
  jinja2,
  # tests
  pytestCheckHook,
  python-multipart,
  pyyaml,
  trio,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "starlette";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Kludex";
    repo = "starlette";
    tag = version;
    hash = "sha256-9iQXlpA1VDGw1c7X1zJPmJ3Dub46PwqrVIX1+fWOZ7M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    trio
    typing-extensions
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];
  dependencies = [ anyio ];

  optional-dependencies.full = [
    itsdangerous
    jinja2
    python-multipart
    pyyaml
    httpx
  ];

  pyproject = true;
  pythonImportsCheck = [ "starlette" ];

  passthru.tests = {
    inherit fastapi;
  };

  meta = {
    description = "Little ASGI framework that shines";
    homepage = "https://www.starlette.io/";
    changelog = "https://github.com/Kludex/starlette/blob/${src.tag}/docs/release-notes.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ wd15 ];
    downloadPage = "https://github.com/Kludex/starlette";
  };
}

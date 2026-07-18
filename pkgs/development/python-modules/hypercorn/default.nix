{
  lib,
  fetchFromGitHub,
  aioquic,
  buildPythonPackage,
  h11,
  h2,
  httpx,
  pdm-backend,
  priority,
  pytest-asyncio,
  pytest-trio,
  pytestCheckHook,
  trio,
  uvloop,
  wsproto,
}:

buildPythonPackage rec {
  pname = "hypercorn";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "pgjones";
    repo = "Hypercorn";
    tag = version;
    hash = "sha256-RNurpDq5Z3N9Wv9Hq/l6A3yKUriCCKx9BrbrWGwBsUk=";
  };

  postPatch = ''
    sed -i "/^addopts/d" pyproject.toml
  '';

  nativeCheckInputs = [
    httpx
    pytest-asyncio
    pytest-trio
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ pdm-backend ];

  dependencies = [
    h11
    h2
    priority
    wsproto
  ];

  optional-dependencies = {
    h3 = [ aioquic ];
    trio = [ trio ];
    uvloop = [ uvloop ];
  };

  pyproject = true;
  pythonImportsCheck = [ "hypercorn" ];

  meta = {
    description = "ASGI web server inspired by Gunicorn";
    homepage = "https://github.com/pgjones/hypercorn";
    changelog = "https://github.com/pgjones/hypercorn/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dgliwka ];
    mainProgram = "hypercorn";
  };
}

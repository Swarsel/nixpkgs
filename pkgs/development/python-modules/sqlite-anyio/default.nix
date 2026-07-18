{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  trio,
}:

buildPythonPackage rec {
  pname = "sqlite-anyio";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "davidbrochart";
    repo = "sqlite-anyio";
    tag = "v${version}";
    hash = "sha256-1riZiLBccg7Vqq+a8xT5Lr4vxjkeMbf1wqXnTTgY8iY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    trio
  ];

  build-system = [ hatchling ];
  dependencies = [ anyio ];
  pyproject = true;
  pythonImportsCheck = [ "sqlite_anyio" ];

  meta = {
    description = "Asynchronous client for SQLite using AnyIO";
    homepage = "https://github.com/davidbrochart/sqlite-anyio";
    changelog = "https://github.com/davidbrochart/sqlite-anyio/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

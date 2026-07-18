{
  lib,
  fetchFromGitHub,
  black,
  buildPythonPackage,
  dirty-equals,
  fastapi,
  jinja2,
  pdm-backend,
  pydantic,
  pytestCheckHook,
  sqlalchemy,
}:

buildPythonPackage (finalAttrs: {
  pname = "sqlmodel";
  version = "0.0.38";

  src = fetchFromGitHub {
    owner = "tiangolo";
    repo = "sqlmodel";
    tag = finalAttrs.version;
    hash = "sha256-GjTqsZVvuTIYxzs7d0bFE6mKPQR4ZlZywGguzOVwHnk=";
  };

  nativeCheckInputs = [
    black
    jinja2
    dirty-equals
    fastapi
    pytestCheckHook
  ];

  build-system = [ pdm-backend ];

  dependencies = [
    pydantic
    sqlalchemy
  ];

  disabledTestPaths = [
    # Coverage
    "docs_src/tutorial/"
    "tests/test_tutorial/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqlmodel" ];

  meta = {
    description = "Module to work with SQL databases";
    homepage = "https://github.com/fastapi/sqlmodel";
    changelog = "https://github.com/fastapi/sqlmodel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

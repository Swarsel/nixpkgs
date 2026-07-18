{
  lib,
  fetchFromGitHub,
  a2wsgi,
  # dependencies
  annotated-doc,
  # tests
  anyio,
  buildPythonPackage,
  dirty-equals,
  email-validator,
  # optional-dependencies
  fastapi-cli,
  flask,
  httpx,
  inline-snapshot,
  itsdangerous,
  jinja2,
  # build-system
  pdm-backend,
  pwdlib,
  pydantic,
  pydantic-extra-types,
  pydantic-settings,
  pyjwt,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  python-multipart,
  pyyaml,
  starlette,
  typing-extensions,
  typing-inspection,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "fastapi";
  version = "0.136.3";

  src = fetchFromGitHub {
    owner = "tiangolo";
    repo = "fastapi";
    tag = version;
    hash = "sha256-lfmk8ZveKPukEEfwWq2mKtWmOHAtVzGuE5BsOskDzh0=";
  };

  nativeCheckInputs = [
    a2wsgi
    anyio
    a2wsgi
    dirty-equals
    flask
    inline-snapshot
    pwdlib
    pyjwt
    pytestCheckHook
    pytest-xdist
    pytest-timeout
  ]
  ++ anyio.optional-dependencies.trio
  ++ optional-dependencies.all;

  build-system = [ pdm-backend ];

  dependencies = [
    annotated-doc
    starlette
    pydantic
    typing-extensions
    typing-inspection
  ];

  disabledTestPaths = [
    # Don't test docs and examples
    "docs_src"
    "tests/test_tutorial"
    # Infinite recursion with strawberry-graphql
    "tests/test_tutorial/test_graphql/test_tutorial001.py"
  ];

  disabledTests = [
    # Coverage test
    "test_fastapi_cli"
  ];

  optional-dependencies = {
    all = [
      fastapi-cli
      httpx
      jinja2
      python-multipart
      itsdangerous
      pyyaml
      email-validator
      uvicorn
      pydantic-settings
      pydantic-extra-types
    ]
    ++ fastapi-cli.optional-dependencies.standard
    ++ uvicorn.optional-dependencies.standard;

    standard = [
      fastapi-cli
      # FIXME package fastar
      httpx
      jinja2
      python-multipart
      email-validator
      uvicorn
      pydantic-settings
      pydantic-extra-types
    ]
    ++ fastapi-cli.optional-dependencies.standard
    ++ uvicorn.optional-dependencies.standard;

    standard-no-fastapi-cloud-cli = [
      fastapi-cli
      httpx
      jinja2
      python-multipart
      email-validator
      uvicorn
      pydantic-settings
      pydantic-extra-types
    ]
    ++ fastapi-cli.optional-dependencies.standard-no-fastapi-cloud-cli
    ++ uvicorn.optional-dependencies.standard;
  };

  pyproject = true;
  pythonImportsCheck = [ "fastapi" ];

  meta = {
    description = "Web framework for building APIs";
    homepage = "https://github.com/fastapi/fastapi";
    changelog = "https://github.com/fastapi/fastapi/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wd15 ];
  };
}

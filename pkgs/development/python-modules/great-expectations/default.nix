{
  lib,
  fetchFromGitHub,
  altair,
  buildPythonPackage,
  click,
  cryptography,
  flaky,
  freezegun,
  invoke,
  jinja2,
  jsonschema,
  marshmallow,
  mistune,
  moto,
  numpy,
  packaging,
  pandas,
  posthog,
  psycopg2,
  pydantic,
  pyparsing,
  pytest-mock,
  pytest-order,
  pytest-random-order,
  # test
  pytestCheckHook,
  python-dateutil,
  requests,
  requirements-parser,
  responses,
  ruamel-yaml,
  scipy,
  setuptools,
  sqlalchemy,
  tqdm,
  tzlocal,
}:

buildPythonPackage (finalAttrs: {
  pname = "great-expectations";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "great-expectations";
    repo = "great_expectations";
    tag = finalAttrs.version;
    hash = "sha256-8yKuEVupqbwlBGeUDu25pvGltybljkmpbkcbC+G+/VI=";
  };

  postPatch = ''
    substituteInPlace tests/conftest.py --replace 'locale.setlocale(locale.LC_ALL, "en_US.UTF-8")' ""
    substituteInPlace pyproject.toml \
      --replace-fail '"ignore::marshmallow.warnings.ChangedInMarshmallow4Warning",' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    pytest-order
    pytest-random-order
    click
    flaky
    freezegun
    invoke
    moto
    psycopg2
    requirements-parser
    responses
    sqlalchemy
  ]
  ++ moto.optional-dependencies.s3
  ++ moto.optional-dependencies.sns;

  build-system = [ setuptools ];

  dependencies = [
    altair
    cryptography
    jinja2
    jsonschema
    marshmallow
    mistune
    numpy
    packaging
    pandas
    posthog
    pydantic
    pyparsing
    python-dateutil
    requests
    ruamel-yaml
    scipy
    tqdm
    tzlocal
  ];

  disabledTestMarks = [
    "postgresql"
    "snowflake"
    "spark"
  ];

  disabledTestPaths = [
    # try to access external URLs:
    "tests/integration/cloud/rest_contracts"
    "tests/integration/spark"

    # moto-related import errors:
    "tests/actions"
    "tests/data_context"
    "tests/datasource"
    "tests/execution_engine"

    # locale-related rendering issues, mostly:
    "tests/core/test__docs_decorators.py"
    "tests/expectations/test_expectation_atomic_renderers.py"
    "tests/render"
  ];

  disabledTests = [
    # tries to access network:
    "test_checkpoint_run_with_data_docs_and_slack_actions_emit_page_links"
    "test_checkpoint_run_with_slack_action_no_page_links"
  ];

  pyproject = true;
  pythonImportsCheck = [ "great_expectations" ];

  pythonRelaxDeps = [
    "altair"
    "pandas"
    "posthog"
  ];

  meta = {
    description = "Library for writing unit tests for data validation";
    homepage = "https://docs.greatexpectations.io";
    changelog = "https://github.com/great-expectations/great_expectations/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
    broken = true; # 408 tests fail
  };
})

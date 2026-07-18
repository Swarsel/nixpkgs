{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  aiosqlite,
  arrow,
  # optional-dependencies
  babel,
  buildPythonPackage,
  cacert,
  colour,
  fasteners,
  # build-system
  hatchling,
  httpx,
  # dependencies
  jinja2,
  mongoengine,
  motor,
  passlib,
  phonenumbers,
  pillow,
  psycopg2,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  python-multipart,
  pythonAtLeast,
  requests,
  sqlalchemy,
  sqlalchemy-file,
  sqlalchemy-utils,
  sqlmodel,
  starlette,
}:

buildPythonPackage rec {
  pname = "starlette-admin";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "jowilf";
    repo = "starlette-admin";
    tag = version;
    hash = "sha256-1hLBGFECucEv1pHDGtk5GXUKUmWWetA72dnn7ayHA4U=";
  };

  patches = [
    # "Cannot use both [tool.pytest] (native TOML types) and [tool.pytest.ini_options] (string-based INI format) simultaneously"
    ./0001-fix-pytest-pyproject-collision.patch
  ];

  nativeCheckInputs = [
    aiosqlite
    arrow
    babel
    cacert
    colour
    fasteners
    httpx
    mongoengine
    motor
    passlib
    phonenumbers
    pillow
    psycopg2
    pydantic
    pytest-asyncio
    pytestCheckHook
    requests
    sqlalchemy
    sqlalchemy-file
    sqlalchemy-utils
    sqlmodel
  ];

  preCheck = ''
    # used in get_test_container in tests/sqla/utils.py
    # fixes FileNotFoundError: [Errno 2] No such file or directory: '/tmp/storage/...'
    mkdir .storage
    export LOCAL_PATH="$PWD/.storage"
  '';

  build-system = [ hatchling ];

  dependencies = [
    jinja2
    python-multipart
    starlette
  ];

  disabledTestPaths = [
    # odmantic is not packaged
    "tests/odmantic"
    # beanie is not packaged
    "tests/beanie"
    # needs mongodb running on port 27017
    "tests/mongoengine"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # very flaky, sandbox issues?
    # libcloud.storage.types.ContainerDoesNotExistError
    # sqlite3.OperationalError: attempt to write a readonly database
    "tests/sqla/test_sync_engine.py"
    "tests/sqla/test_async_engine.py"
  ];

  disabledTests =
    lib.optionals (pythonAtLeast "3.14") [
      # AssertionError: Regex pattern did not match
      "test_not_supported_annotation"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # flaky, depends on test order
      "test_ensuring_pk"
      # flaky, of-by-one
      "test_api"
    ];

  optional-dependencies = {
    i18n = [ babel ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "starlette_admin"
    "starlette_admin.actions"
    "starlette_admin.base"
    "starlette_admin.fields"
    "starlette_admin.i18n"
    "starlette_admin.tools"
    "starlette_admin.views"
  ];

  meta = {
    description = "Fast, beautiful and extensible administrative interface framework for Starlette & FastApi applications";
    homepage = "https://github.com/jowilf/starlette-admin";
    changelog = "https://jowilf.github.io/starlette-admin/changelog/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}

{
  lib,
  fetchFromGitHub,
  # sqlalchemy-with-utils
  arrow,
  # azure-blob-storage
  azure-storage-blob,
  # checks
  beautifulsoup4,
  # s3
  boto3,
  buildPythonPackage,
  colour,
  email-validator,
  # dependencies
  flask,
  # translation
  flask-babel,
  # optional dependencies
  # sqlalchemy
  flask-sqlalchemy,
  # sqlalchemy-lite
  flask-sqlalchemy-lite,
  flit-core,
  # geoalchemy
  geoalchemy2,
  jinja2,
  markupsafe,
  # mongoengine
  mongoengine,
  moto,
  # peewee
  peewee,
  # images
  pillow,
  psycopg2,
  # pymongo
  pymongo,
  pytestCheckHook,
  # rediscli
  redis,
  shapely,
  sqlalchemy,
  sqlalchemy-citext,
  sqlalchemy-utils,
  # export
  tablib,
  werkzeug,
  wtf-peewee,
  wtforms,
}:

buildPythonPackage rec {
  pname = "flask-admin";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "flask-admin";
    repo = "flask-admin";
    tag = "v${version}";
    hash = "sha256-lRLyGvCat6nBixFKkrn4NxeVF52Hl32admAL37mf9wc=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    moto
    psycopg2
    pytestCheckHook
  ]
  ++ lib.flatten [
    optional-dependencies.sqlalchemy-lite
    optional-dependencies.sqlalchemy-with-utils
    optional-dependencies.mongoengine
    optional-dependencies.peewee
    optional-dependencies.images
    optional-dependencies.export
    optional-dependencies.translation
    flask.optional-dependencies.async
  ];

  build-system = [ flit-core ];

  dependencies = [
    flask
    jinja2
    markupsafe
    werkzeug
    wtforms
  ];

  disabledTestPaths = [
    # requires database
    "flask_admin/tests/geoa/test_basic.py"
    "flask_admin/tests/pymongo/test_basic.py"
    "flask_admin/tests/mongoengine/test_basic.py"
    "flask_admin/tests/peeweemodel/test_basic.py"
    "flask_admin/tests/sqla/test_postgres.py"
    # requires internet
    "flask_admin/tests/fileadmin/test_fileadmin_azure.py"
  ];

  optional-dependencies = {
    all = lib.flatten [
      optional-dependencies.sqlalchemy
      optional-dependencies.sqlalchemy-with-utils
      optional-dependencies.geoalchemy
      optional-dependencies.pymongo
      optional-dependencies.mongoengine
      optional-dependencies.peewee
      optional-dependencies.s3
      optional-dependencies.azure-blob-storage
      optional-dependencies.images
      optional-dependencies.export
      optional-dependencies.rediscli
      optional-dependencies.translation
    ];

    azure-blob-storage = [ azure-storage-blob ];
    export = [ tablib ];

    geoalchemy = optional-dependencies.sqlalchemy ++ [
      geoalchemy2
      shapely
    ];

    images = [ pillow ];
    mongoengine = [ mongoengine ];

    peewee = [
      peewee
      wtf-peewee
    ];

    pymongo = [ pymongo ];
    rediscli = [ redis ];
    s3 = [ boto3 ];

    sqlalchemy = [
      flask-sqlalchemy
      sqlalchemy
    ];

    sqlalchemy-lite = [
      flask-sqlalchemy-lite
    ];

    sqlalchemy-with-utils = optional-dependencies.sqlalchemy ++ [
      arrow
      colour
      email-validator
      sqlalchemy-citext
      sqlalchemy-utils
    ];

    translation = [ flask-babel ];
  };

  pyproject = true;
  pythonImportsCheck = [ "flask_admin" ];

  meta = {
    description = "Admin interface framework for Flask";
    homepage = "https://github.com/flask-admin/flask-admin/";
    changelog = "https://github.com/flask-admin/flask-admin/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}

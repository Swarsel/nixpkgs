{
  lib,
  fetchFromGitHub,
  alembic,
  buildPythonPackage,
  packaging,
  pytest-benchmark,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  shapely,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "geoalchemy2";
  version = "0.18.4";

  src = fetchFromGitHub {
    owner = "geoalchemy";
    repo = "geoalchemy2";
    tag = version;
    hash = "sha256-kSsKud4/uL5ycPiuS+JPXJ6XH9ZgQ+kHOTC5RtG9C0I=";
  };

  nativeCheckInputs = [
    alembic
    pytest-benchmark
    pytestCheckHook
  ]
  ++ optional-dependencies.shapely;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    sqlalchemy
    packaging
  ];

  disabledTestPaths = [
    # tests require live databases
    "tests/gallery/test_decipher_raster.py"
    "tests/gallery/test_length_at_insert.py"
    "tests/gallery/test_insert_raster.py"
    "tests/gallery/test_orm_mapped_v2.py"
    "tests/gallery/test_specific_compilation.py"
    "tests/gallery/test_summarystatsagg.py"
    "tests/gallery/test_type_decorator.py"
    "tests/test_functional.py"
    "tests/test_functional_postgresql.py"
    "tests/test_functional_mysql.py"
    "tests/test_alembic_migrations.py"
    "tests/test_pickle.py"
  ];

  optional-dependencies = {
    shapely = [ shapely ];
  };

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "geoalchemy2" ];

  meta = {
    description = "Toolkit for working with spatial databases";
    homepage = "https://geoalchemy-2.readthedocs.io/";
    changelog = "https://github.com/geoalchemy/geoalchemy2/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  libpq,
  postgresql,
  postgresqlTestHook,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "psycopg2cffi";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "chtd";
    repo = "psycopg2cffi";
    tag = version;
    hash = "sha256-9r5MYxw9cvdbLVj8StmMmn0AKQepOpCc7TIBGXZGWe4=";
  };

  postPatch = ''
    substituteInPlace psycopg2cffi/_impl/_build_libpq.py \
      --replace-fail "from distutils import sysconfig" "import sysconfig" \
      --replace-fail "sysconfig.get_python_inc()" "sysconfig.get_path('include')"
  '';

  nativeBuildInputs = [ libpq.pg_config ];
  buildInputs = [ libpq ];

  env = {
    PGDATABASE = "psycopg2_test";
  };

  # FATAL: could not create shared memory segment: Operation not permitted
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    cffi
    six
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.13") [
    # testutils.script_to_py3 imports lib2to3, removed in 3.13
    "psycopg2cffi/tests/psycopg2_tests/test_notify.py"
  ];

  disabledTests = [
    # AssertionError: '{}' != []
    "testEmptyArray"
  ];

  pyproject = true;
  pythonImportsCheck = [ "psycopg2cffi" ];

  meta = {
    description = "Implementation of the psycopg2 module using cffi";
    homepage = "https://pypi.org/project/psycopg2cffi/";
    license = with lib.licenses; [ lgpl3Plus ];
    maintainers = with lib.maintainers; [ lovesegfault ];
  };
}

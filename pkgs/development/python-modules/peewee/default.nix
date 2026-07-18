{
  lib,
  fetchFromGitHub,
  apsw,
  buildPythonPackage,
  cython,
  flask,
  mysql-connector-python,
  psycopg2,
  python,
  setuptools,
  sqlite,
  withMysql ? false,
  withPostgres ? false,
}:

buildPythonPackage rec {
  pname = "peewee";
  version = "3.19.0";

  src = fetchFromGitHub {
    owner = "coleifer";
    repo = "peewee";
    tag = version;
    hash = "sha256-EO8gS5fMZ1GgJV2YMjy15XQGZa72fZF7dgG7RZUE9dA=";
  };

  buildInputs = [
    sqlite
    cython
  ];

  propagatedBuildInputs = [
    apsw
  ]
  ++ lib.optionals withPostgres [ psycopg2 ]
  ++ lib.optionals withMysql [ mysql-connector-python ];

  doCheck = withPostgres;
  nativeCheckInputs = [ flask ];

  checkPhase = ''
    rm -r playhouse # avoid using the folder in the cwd
    ${python.interpreter} runtests.py
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "peewee" ];

  meta = {
    description = "Python ORM with support for various database implementation";
    homepage = "http://peewee-orm.com";
    changelog = "https://github.com/coleifer/peewee/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pwiz.py";
  };
}

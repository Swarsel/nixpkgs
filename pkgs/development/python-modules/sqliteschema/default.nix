{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mbstrdecoder,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  simplesqlite,
  sqliteschema,
  tabledata,
  typepy,
}:

buildPythonPackage rec {
  pname = "sqliteschema";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "thombashi";
    repo = "sqliteschema";
    tag = "v${version}";
    hash = "sha256-ZGDzGfj78v8o0GvAHcP26JiJCOWPaIr2h1Lqzh5AuSg=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    mbstrdecoder
    tabledata
    typepy
  ];

  # Enabling tests would trigger infinite recursion due to circular
  # dependency between this package and simplesqlite.
  # Therefore, we enable tests only when building passthru.tests.
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    simplesqlite
    sqliteschema
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqliteschema" ];

  passthru.tests.pytest = sqliteschema.overridePythonAttrs (_: {
    doCheck = true;
  });

  meta = {
    description = "Python library to dump table schema of a SQLite database file";
    homepage = "https://github.com/thombashi/sqliteschema";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ henrirosten ];
  };
}

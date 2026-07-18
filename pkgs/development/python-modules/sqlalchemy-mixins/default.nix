{
  lib,
  fetchFromGitHub,
  aiosqlite,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  six,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "sqlalchemy-mixins";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "absent1706";
    repo = "sqlalchemy-mixins";
    tag = "v${version}";
    hash = "sha256-0uB3x7RQSNEq3DyTSiOIGajwPQQEBjXK8HOyuXCNa/E=";
  };

  nativeCheckInputs = [
    aiosqlite
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    six
    sqlalchemy
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqlalchemy_mixins" ];

  meta = {
    description = "Python mixins for SQLAlchemy ORM";
    homepage = "https://github.com/absent1706/sqlalchemy-mixins";
    changelog = "https://github.com/absent1706/sqlalchemy-mixins/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

{
  lib,
  fetchFromGitHub,
  aiosqlite,
  asyncmy,
  buildPythonPackage,
  psycopg,
  # test
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "mayim";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "ahopkins";
    repo = "mayim";
    tag = "v${version}";
    hash = "sha256-HEnzHpgTbEZOBzUG7DDIO9YRWIoLroLY+Spq/jkMib0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ]
  ++ (
    with optional-dependencies;
    lib.concatLists [
      postgres
      mysql
      sqlite
    ]
  );

  build-system = [
    setuptools
    wheel
  ];

  optional-dependencies = {
    mysql = [ asyncmy ];
    postgres = [ psycopg ] ++ psycopg.optional-dependencies.pool;
    sqlite = [ aiosqlite ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mayim" ];

  meta = {
    description = "Asynchronous SQL hydrator";
    homepage = "https://github.com/ahopkins/mayim";
    changelog = "https://github.com/ahopkins/mayim/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ huyngo ];
  };
}

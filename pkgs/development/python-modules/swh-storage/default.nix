{
  lib,
  stdenv,
  fetchFromGitLab,
  backports-entry-points-selectable,
  buildPythonPackage,
  cassandra-driver,
  click,
  deprecated,
  flask,
  iso8601,
  mypy-extensions,
  postgresql,
  postgresqlTestHook,
  psycopg,
  psycopg-pool,
  pyasyncore,
  pytest-aiohttp,
  pytest-mock,
  pytest-postgresql,
  pytest-shared-session-scope,
  pytest-xdist,
  pytestCheckHook,
  redis,
  setuptools,
  setuptools-scm,
  swh-core,
  swh-journal,
  swh-model,
  swh-objstorage,
  tenacity,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-storage";
  version = "4.2.0";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-storage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l9ElZtpJBryFvBLtXQZ7NiYH6FvyarmoWzTkTg7E8gw=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  # Many broken tests on Darwin. Disabling them for now.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
    pytest-aiohttp
    pytest-mock
    pytest-postgresql
    pytest-shared-session-scope
    pytest-xdist
    pytestCheckHook
    swh-journal
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    backports-entry-points-selectable
    cassandra-driver
    click
    deprecated
    flask
    iso8601
    mypy-extensions
    psycopg
    psycopg-pool
    pyasyncore
    redis
    tenacity
    swh-core
    swh-model
    swh-objstorage
  ];

  disabledTestPaths = [
    # E       fixture 'redisdb' not found
    "swh/storage/tests/test_replay.py"
    # Unable to setup the local Cassandra database
    "swh/storage/tests/test_cassandra.py"
    "swh/storage/tests/test_cassandra_converters.py"
    "swh/storage/tests/test_cassandra_diagram.py"
    "swh/storage/tests/test_cassandra_migration.py"
    "swh/storage/tests/test_cassandra_ttl.py"
    "swh/storage/tests/test_cli_cassandra.py"
    "swh/storage/tests/test_cli_object_references_cassandra.py"
    # Failing tests
    "swh/storage/tests/test_cli_object_references.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "swh.storage" ];

  meta = {
    description = "Abstraction layer over the archive, allowing to access all stored source code artifacts as well as their metadata";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-storage";
    changelog = "https://gitlab.softwareheritage.org/swh/devel/swh-storage/-/tags/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})

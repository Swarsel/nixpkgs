{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  celery,
  flask,
  humanize,
  importlib-metadata,
  pika,
  plotille,
  postgresql,
  postgresqlTestHook,
  psycopg,
  pytest-mock,
  pytest-postgresql,
  pytest-shared-session-scope,
  pytest-xdist,
  pytestCheckHook,
  requests-mock,
  setuptools,
  setuptools-scm,
  simpy,
  swh-journal,
  swh-storage,
  tabulate,
  types-python-dateutil,
  types-pyyaml,
  types-requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-scheduler";
  version = "3.3.2";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-scheduler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ELjxZKWCsAQte+KtSdwseMGnMdw65H9PrjuJP0PHtIM=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  # Many broken tests on Darwin. Disabling them for now.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    plotille
    postgresql
    postgresqlTestHook
    pytestCheckHook
    pytest-mock
    pytest-postgresql
    pytest-shared-session-scope
    pytest-xdist
    requests-mock
    simpy
    swh-journal
    types-python-dateutil
    types-pyyaml
    types-requests
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    celery
    flask
    humanize
    importlib-metadata
    pika
    psycopg
    tabulate
    swh-storage
  ];

  disabledTests = [
    "test_setup_log_handler_with_env_configuration"
    "test_task_exception"
  ];

  pyproject = true;
  pythonImportsCheck = [ "swh.scheduler" ];

  meta = {
    description = "Job scheduler for the Software Heritage project";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-scheduler";
    changelog = "https://gitlab.softwareheritage.org/swh/devel/swh-scheduler/-/tags/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})

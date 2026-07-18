{
  lib,
  stdenv,
  fetchFromGitLab,
  # tests
  aiohttp-utils,
  # dependencies
  backports-entry-points-selectable,
  buildPythonPackage,
  click,
  deprecated,
  flask,
  hypothesis,
  iso8601,
  lzip,
  moto,
  msgpack,
  pkgs, # Only for pkgs.zstd
  postgresql,
  postgresqlTestHook,
  psycopg,
  pylzma,
  pytest-aiohttp,
  pytest-mock,
  pytest-postgresql,
  pytestCheckHook,
  python-magic,
  pythonAtLeast,
  pytz,
  pyyaml,
  requests,
  requests-mock,
  sentry-sdk,
  # build-system
  setuptools,
  setuptools-scm,
  swh-model,
  systemd-python,
  tenacity,
  tqdm,
  types-deprecated,
  types-psycopg2,
  types-pytz,
  types-pyyaml,
  types-requests,
  unzip,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-core";
  version = "4.6.2";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CMTdRP1S9m2d9TiZEr491fcN5zpJtJ3N4hfpVTHfrnY=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  # Many broken tests on Darwin. Disabling them for now.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    aiohttp-utils
    flask
    hypothesis
    iso8601
    lzip
    moto
    msgpack
    postgresql
    postgresqlTestHook
    pylzma
    pytestCheckHook
    pytest-aiohttp
    pytest-mock
    pytest-postgresql
    pytz
    requests-mock
    swh-model
    systemd-python
    tqdm
    types-deprecated
    types-psycopg2
    types-pytz
    types-pyyaml
    types-requests
    unzip
    pkgs.zstd
  ]
  ++ psycopg.optional-dependencies.pool;

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    backports-entry-points-selectable
    click
    deprecated
    python-magic
    pyyaml
    requests
    sentry-sdk
    tenacity
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.14") [
    # shutil.RegistryError: .tar.zst is already registered for "zstdtar"
    "swh/core/tests/test_cli_nar.py"
    "swh/core/tests/test_nar.py"
    "swh/core/tests/test_tarball.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # FileExistsError: [Errno 17] File exists:
    "test_uncompress_upper_archive_extension"
    # AssertionError: |500 - 632.1152460000121| not within 100
    "test_timed_coroutine"
    "test_timed_start_stop_calls"
    "test_timed"
    "test_timed_no_metric"
  ];

  pyproject = true;
  pythonImportsCheck = [ "swh.core" ];

  pythonRelaxDeps = [
    # we patched click 8.2.1
    "click"
  ];

  meta = {
    description = "Low-level utilities and helpers used by almost all other modules in the stack";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-core";
    changelog = "https://gitlab.softwareheritage.org/swh/devel/swh-core/-/tags/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "swh";
  };
})

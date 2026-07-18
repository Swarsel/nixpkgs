{
  lib,
  fetchFromGitHub,
  boto3,
  botocore,
  buildPythonPackage,
  debugpy,
  docker,
  kombu,
  poetry-core,
  psutil,
  pytest,
  pytest-docker-tools,
  python-memcached,
  # optional dependencies
  redis,
  tenacity,
  urllib3,
}:

buildPythonPackage rec {
  pname = "pytest-celery";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "celery";
    repo = "pytest-celery";
    tag = "v${version}";
    hash = "sha256-8qDnyMv0NxMFWGRbJ63Ye/dSRr8A6Azh2J5gkiwYYzI=";
  };

  postPatch = ''
    # Avoid infinite recursion with celery
    substituteInPlace pyproject.toml \
      --replace 'celery = { version = "*" }' ""
  '';

  buildInputs = [ pytest ];
  # Infinite recursion with celery
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    debugpy
    docker
    kombu
    psutil
    pytest-docker-tools
    tenacity
  ];

  optional-dependencies = {
    all = [
      redis
      python-memcached
      boto3
      botocore
      urllib3
    ];

    memcached = [ python-memcached ];
    redis = [ redis ];

    sqs = [
      boto3
      botocore
      urllib3
    ];
  };

  pyproject = true;

  pythonRelaxDeps = [
    "debugpy"
  ];

  pythonRemoveDeps = [
    "celery" # cyclic dependency
    "setuptools" # https://github.com/celery/pytest-celery/pull/464
  ];

  meta = {
    description = "Pytest plugin to enable celery.contrib.pytest";
    homepage = "https://github.com/celery/pytest-celery";
    changelog = "https://github.com/celery/pytest-celery/blob/${src.tag}/Changelog.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

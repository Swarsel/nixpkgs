{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  gevent,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-tornado,
  pytest8_3CheckHook,
  pytz,
  setuptools-scm,
  setuptools_80,
  tornado,
  twisted,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "apscheduler";
  version = "3.11.2";

  src = fetchFromGitHub {
    owner = "agronholm";
    repo = "apscheduler";
    tag = version;
    hash = "sha256-AhVlACRg0Xwy9XmFRl29of5uM2aJa5Gv2SzFuJXVCpE=";
  };

  postPatch = ''
    sed -i "/addopts/d" pyproject.toml
  '';

  nativeCheckInputs = [
    gevent
    pytest-asyncio
    pytest-cov-stub
    pytest-tornado
    pytest8_3CheckHook
    pytz
    tornado
    twisted
  ];

  build-system = [
    setuptools_80
    setuptools-scm
  ];

  dependencies = [
    tzlocal
  ];

  disabledTests = [
    "test_broken_pool"
    # gevent tests have issue on newer Python releases
    "test_add_live_job"
    "test_add_pending_job"
    "test_shutdown"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "test_submit_job"
    "test_max_instances"
  ];

  pyproject = true;
  pythonImportsCheck = [ "apscheduler" ];

  meta = {
    description = "Library that lets you schedule your Python code to be executed";
    homepage = "https://github.com/agronholm/apscheduler";
    changelog = "https://github.com/agronholm/apscheduler/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

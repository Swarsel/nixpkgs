{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  netcat,
  ps,
  psutil,
  pytest-rerunfailures,
  pytest-xdist,
  pytestCheckHook,
  python-daemon,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mirakuru";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "ClearcodeHQ";
    repo = "mirakuru";
    tag = "v${version}";
    hash = "sha256-3WyjvHxr+6kG+cLSCEZkHoA70mSoT66ubmp0W9g2yJM=";
  };

  postPatch = ''
    substituteInPlace tests/executors/test_output_executor_regression_issue_98.py \
      --replace-fail "timeout=15," "timeout=60,"
  '';

  nativeCheckInputs = [
    netcat.nc
    ps
    python-daemon
    pytest-rerunfailures
    pytest-xdist
    pytestCheckHook
  ];

  # Necessary for the tests to pass on Darwin with sandbox enabled.
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ psutil ];

  # Those are failing in the darwin sandbox with:
  # > ps: %mem: requires entitlement
  # > ps: vsz: requires entitlement
  # > ps: rss: requires entitlement
  # > ps: time: requires entitlement
  disabledTests = [
    "test_forgotten_stop"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "test_mirakuru_cleanup"
    "test_daemons_killing"
  ];

  # socket bind races, but requires xdist_group
  dontUsePytestXdist = true;
  pyproject = true;
  pythonImportsCheck = [ "mirakuru" ];

  meta = {
    description = "Process orchestration tool designed for functional and integration tests";
    homepage = "https://github.com/dbfixtures/mirakuru";
    changelog = "https://github.com/ClearcodeHQ/mirakuru/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}

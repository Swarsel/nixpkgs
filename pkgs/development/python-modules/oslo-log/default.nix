{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  debtcollector,
  # tests
  eventlet,
  oslo-config,
  oslo-context,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  pyinotify,
  pytestCheckHook,
  python-dateutil,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "oslo-log";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "oslo.log";
    tag = version;
    hash = "sha256-ThRJ2rfVStnVOwcu8ZaKDjqb4jT6YE+n+iOFtmR8rwQ=";
  };

  # Manually set version because prb wants to get it from the git upstream repository (and we are
  # installing from tarball instead)
  env.PBR_VERSION = version;

  nativeCheckInputs = [
    eventlet
    oslotest
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    debtcollector
    oslo-config
    oslo-context
    oslo-serialization
    oslo-utils
    pbr
    python-dateutil
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pyinotify ];

  disabledTests = [
    # not compatible with sandbox
    "test_logging_handle_error"
    # Incompatible Exception Representation, displaying natively
    "test_rate_limit"
    "test_rate_limit_except_level"
  ];

  pyproject = true;
  pythonImportsCheck = [ "oslo_log" ];

  meta = {
    description = "oslo.log library";
    homepage = "https://github.com/openstack/oslo.log";
    license = lib.licenses.asl20;
    mainProgram = "convert-json";
    teams = [ lib.teams.openstack ];
  };
}

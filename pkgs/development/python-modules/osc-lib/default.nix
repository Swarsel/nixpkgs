{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cliff,
  keystoneauth1,
  openstacksdk,
  oslo-i18n,
  oslo-utils,
  pbr,
  requests,
  requests-mock,
  setuptools,
  stestr,
  stevedore,
}:

buildPythonPackage rec {
  pname = "osc-lib";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "osc-lib";
    tag = version;
    hash = "sha256-XwOJSd3k/74FvSZGveSTjH+KGLlQ2jNbk8GrTzFhbL0=";
  };

  patches = [
    ./fix-pyproject.diff
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    requests-mock
    stestr
  ];

  checkPhase =
    let
      disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
        "osc_lib.tests.test_shell.TestShellCli.test_shell_args_cloud_public"
        "osc_lib.tests.test_shell.TestShellCli.test_shell_args_precedence"
        "osc_lib.tests.test_shell.TestShellCliPrecedence.test_shell_args_precedence_1"
        "osc_lib.tests.test_shell.TestShellCliPrecedence.test_shell_args_precedence_2"
      ];
    in
    ''
      runHook preCheck
      stestr run -e <(echo "${lib.concatStringsSep "\n" disabledTests}")
      runHook postCheck
    '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    cliff
    keystoneauth1
    openstacksdk
    oslo-i18n
    oslo-utils
    requests
    stevedore
  ];

  pyproject = true;

  pythonImportsCheck = [
    "osc_lib"
    "osc_lib.api"
    "osc_lib.cli"
    "osc_lib.command"
    "osc_lib.test"
    "osc_lib.tests"
    "osc_lib.tests.api"
    "osc_lib.tests.cli"
    "osc_lib.tests.command"
    "osc_lib.tests.utils"
    "osc_lib.utils"
  ];

  meta = {
    description = "OpenStackClient Library";
    homepage = "https://github.com/openstack/osc-lib";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}

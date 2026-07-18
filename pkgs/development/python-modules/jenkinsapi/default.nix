{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  mock,
  pytest-mock,
  pytestCheckHook,
  pytz,
  requests,
  six,
}:

buildPythonPackage rec {
  pname = "jenkinsapi";
  version = "0.3.17";

  src = fetchFromGitHub {
    owner = "pycontribs";
    repo = "jenkinsapi";
    tag = version;
    hash = "sha256-1dTcT84cDpP9V4tVrgW2MTYx4jQj0/tZiAuakC+orUQ=";
  };

  nativeCheckInputs = [
    mock
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    pytz
    requests
    six
  ];

  # don't run tests that try to spin up jenkins
  disabledTests = [ "systests" ];
  pyproject = true;

  pythonImportsCheck = [
    "jenkinsapi"
    "jenkinsapi.utils"
    "jenkinsapi.utils.jenkins_launcher"
  ];

  meta = {
    description = "Python API for accessing resources on a Jenkins continuous-integration server";
    homepage = "https://github.com/salimfadhley/jenkinsapi";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      de11n
      despsyched
      drets
    ];
  };
}

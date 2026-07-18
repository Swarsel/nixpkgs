{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  requests,
  urllib3,
  waitress,
}:

buildPythonPackage rec {
  pname = "requests-unixsocket2";
  version = "1.0.1";

  src = fetchFromGitLab {
    owner = "thelabnyc";
    repo = "requests-unixsocket2";
    tag = "v${version}";
    hash = "sha256-KgPIecKQibB5ZH+itw3OM9heSE3uDuodNS1R9dRkaHE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    waitress
  ];

  build-system = [ hatchling ];

  dependencies = [
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "requests_unixsocket" ];

  meta = {
    description = "Use requests to talk HTTP via a UNIX domain socket";
    homepage = "https://gitlab.com/thelabnyc/requests-unixsocket2";
    changelog = "https://gitlab.com/thelabnyc/requests-unixsocket2/-/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ mikut ];
  };
}

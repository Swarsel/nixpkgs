{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pyjwt,
  pytestCheckHook,
  python-dateutil,
  requests,
}:

buildPythonPackage rec {
  pname = "messagebird";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "messagebird";
    repo = "python-rest-api";
    rev = version;
    hash = "sha256-OiLhnmZ725VbyoOHvSf4nKQRA7JsxqcOv0VKBL6rUtU=";
  };

  propagatedBuildInputs = [
    pyjwt
    python-dateutil
    requests
  ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  disabledTestPaths = [
    # ValueError: not enough values to unpack (expected 6, got 0)
    "tests/test_request_validator.py"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "messagebird" ];

  meta = {
    description = "Client for MessageBird's REST API";
    homepage = "https://github.com/messagebird/python-rest-api";
    license = with lib.licenses; [ bsd2 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}

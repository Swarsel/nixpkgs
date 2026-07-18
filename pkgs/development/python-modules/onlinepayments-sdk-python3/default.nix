{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mockito,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "onlinepayments-sdk-python3";
  version = "4.23.0";

  src = fetchFromGitHub {
    owner = "wl-online-payments-direct";
    repo = "sdk-python3";
    rev = finalAttrs.version;
    hash = "sha256-IX9kiM5ZtX4uzW+D+Bbt8535CqMtdTtv0mpDo5Swstg=";
  };

  nativeCheckInputs = [
    mockito
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    requests-toolbelt
  ];

  disabledTestPaths = [
    # requires api key
    "tests/integration"
  ];

  disabledTests = [
    # missing fixtures
    "testConnection_request"
    "testConnection_response"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "onlinepayments"
  ];

  meta = {
    description = "SDK to communicate with the Online Payments platform using the Online Payments Server API";
    homepage = "https://github.com/wl-online-payments-direct/sdk-python3";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})

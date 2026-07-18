{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycryptodome,
  # dependencies for tests
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  sure,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "binance-connector";
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "binance";
    repo = "${pname}-python";
    tag = "v${version}";
    hash = "sha256-8O73+fli0HNbvGBcyg79ZGOTQvL0TF5SCfogI6btlrA=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    sure
    responses
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    pycryptodome
    websocket-client
  ];

  # pytestCheckHook attempts to run examples directory, which requires
  # network access
  disabledTestPaths = [ "examples/" ];
  pyproject = true;

  pythonImportsCheck = [
    "binance.spot"
    "binance.websocket"
  ];

  meta = {
    description = "Simple connector to Binance Public API";
    homepage = "https://github.com/binance/binance-connector-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ trishtzy ];
  };
}

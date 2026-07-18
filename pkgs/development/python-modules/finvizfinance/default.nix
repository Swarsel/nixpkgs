{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  datetime,
  lxml,
  pandas,
  pytest-mock,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "finvizfinance";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "lit26";
    repo = "finvizfinance";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M/EyQgINdJLLfOFNm/RhqONz3slb4ukugHLdiozDY0s=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    datetime
    lxml
    pandas
    requests
  ];

  disabledTests = [
    # Tests require network access
    "test_finvizfinance_calendar"
    "test_finvizfinance_crypto"
    "test_finvizfinance_finvizfinance"
    "test_finvizfinance_insider"
    "test_finvizfinance_news"
    "test_forex_performance_percentage"
    "test_group_overview"
    "test_screener_overview"
    "test_statements"
    "test_ticker_etf_holders_returns_list"
    "test_ticker_peer_returns_list"
  ];

  pyproject = true;
  pythonImportsCheck = [ "finvizfinance" ];

  meta = {
    description = "Finviz Finance information downloader";
    homepage = "https://github.com/lit26/finvizfinance";
    changelog = "https://github.com/lit26/finvizfinance/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ icyrockcom ];
  };
})

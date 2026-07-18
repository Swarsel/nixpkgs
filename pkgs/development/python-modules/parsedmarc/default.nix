{
  lib,
  fetchurl,
  fetchFromGitHub,
  # dependencies
  azure-identity,
  azure-monitor-ingestion,
  boto3,
  buildPythonPackage,
  dateparser,
  dnspython,
  elasticsearch,
  elasticsearch-dsl,
  expiringdict,
  # build-system
  hatchling,
  kafka-python,
  lxml,
  mailsuite,
  maxminddb,
  nixosTests,
  opensearch-py,
  publicsuffixlist,
  pygelf,
  # test
  pytestCheckHook,
  pyyaml,
  requests,
  tqdm,
  urllib3,
  xmltodict,
}:

let
  dashboard = fetchurl {
    sha256 = "0wbihyqbb4ndjg79qs8088zgrcg88km8khjhv2474y7nzjzkf43i";
    url = "https://raw.githubusercontent.com/domainaware/parsedmarc/77331b55c54cb3269205295bd57d0ab680638964/grafana/Grafana-DMARC_Reports.json";
  };
in
buildPythonPackage rec {
  pname = "parsedmarc";
  version = "10.2.0";

  src = fetchFromGitHub {
    owner = "domainaware";
    repo = "parsedmarc";
    tag = version;
    hash = "sha256-ed6t96CcemrUE6NtBmP1Am7l7dYmcNLGFN8slTSfgOM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires_python = ">=3.10,<3.15"' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    azure-identity
    azure-monitor-ingestion
    boto3
    dateparser
    dnspython
    elasticsearch
    elasticsearch-dsl
    expiringdict
    kafka-python
    lxml
    mailsuite
    maxminddb
    opensearch-py
    publicsuffixlist
    pygelf
    pyyaml
    requests
    tqdm
    urllib3
    xmltodict
  ]
  ++ mailsuite.optional-dependencies.gmail
  ++ mailsuite.optional-dependencies.msgraph;

  disabledTests = [
    # contacts DNS servers at 1.1.1.1 and 8.8.8.8
    "test_general_dns_settings_with_defaults"
  ];

  pyproject = true;
  pythonImportsCheck = [ "parsedmarc" ];

  pythonRelaxDeps = [
    "elasticsearch"
    "elasticsearch-dsl"
  ];

  passthru = {
    inherit dashboard;
    tests = nixosTests.parsedmarc;
  };

  meta = {
    description = "Python module and CLI utility for parsing DMARC reports";
    homepage = "https://domainaware.github.io/parsedmarc/";
    changelog = "https://github.com/domainaware/parsedmarc/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ talyz ];
    mainProgram = "parsedmarc";
  };
}

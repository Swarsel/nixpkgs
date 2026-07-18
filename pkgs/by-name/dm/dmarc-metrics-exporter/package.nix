{
  lib,
  stdenv,
  fetchFromGitHub,
  python312,
}:

let
  # more-itertools unsupported on 3.13
  python3 = python312;
in

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "dmarc-metrics-exporter";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "jgosmann";
    repo = "dmarc-metrics-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Mp4gQi+cLAoVKVSmGbgruPYPVJV6vxwzVOnx+CZhxS8=";
  };

  nativeCheckInputs = with python3.pkgs; [
    aiohttp
    pytest-asyncio
    pytestCheckHook
    requests
  ];

  build-system = with python3.pkgs; [
    poetry-core
  ];

  dependencies =
    with python3.pkgs;
    [
      bite-parser
      dataclasses-serialization
      prometheus-client
      pydantic
      structlog
      uvicorn
      xsdata
    ]
    ++ uvicorn.optional-dependencies.standard;

  disabledTestPaths = [
    # require networking
    "dmarc_metrics_exporter/tests/test_e2e.py"
    "dmarc_metrics_exporter/tests/test_imap_client.py"
    "dmarc_metrics_exporter/tests/test_imap_queue.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # flaky tests
    "test_build_info"
    "test_prometheus_exporter"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dmarc_metrics_exporter" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Export Prometheus metrics from DMARC reports";
    homepage = "https://github.com/jgosmann/dmarc-metrics-exporter";
    changelog = "https://github.com/jgosmann/dmarc-metrics-exporter/blob/v${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ma27 ];
    mainProgram = "dmarc-metrics-exporter";
  };
})

{
  lib,
  fetchFromGitHub,
  borgmatic,
  nixosTests,
  python3Packages,
}:

python3Packages.buildPythonApplication (finallAttrs: {
  pname = "prometheus-borgmatic-exporter";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "maxim-mityutko";
    repo = "borgmatic-exporter";
    tag = "v${finallAttrs.version}";
    hash = "sha256-pa1f31jrfDzUB3+xexJUwG0byiFszj/zEt+dIwlEv0o=";
  };

  propagatedBuildInputs = [
    borgmatic
  ]
  ++ (with python3Packages; [
    arrow
    click
    flask
    loguru
    pretty-errors
    prometheus-client
    timy
    waitress
    flask-caching
  ]);

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-mock
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = with python3Packages; [ poetry-core ];
  pyproject = true;
  pythonRelaxDeps = [ "prometheus-client" ];
  passthru.tests.borgmatic = nixosTests.prometheus-exporters.borgmatic;

  meta = {
    description = "Prometheus exporter for Borgmatic";
    homepage = "https://github.com/maxim-mityutko/borgmatic-exporter";
    changelog = "https://github.com/maxim-mityutko/borgmatic-exporter/releases/tag/${finallAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flandweber ];
    platforms = lib.platforms.unix;
    mainProgram = "borgmatic-exporter";
  };
})

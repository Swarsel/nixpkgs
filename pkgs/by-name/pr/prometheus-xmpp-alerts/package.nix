{
  lib,
  fetchFromGitHub,
  prometheus-alertmanager,
  prometheus-xmpp-alerts,
  python3Packages,
  runCommand,
}:

python3Packages.buildPythonApplication rec {
  pname = "prometheus-xmpp-alerts";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "jelmer";
    repo = "prometheus-xmpp-alerts";
    rev = "v${version}";
    sha256 = "sha256-kXcadJnPPhMKF/1CHMLdGCqWouAKDBFTdvPpn80yK4A=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "bs4" "beautifulsoup4"
  '';

  propagatedBuildInputs = [
    prometheus-alertmanager
  ]
  ++ (with python3Packages; [
    aiohttp
    aiohttp-openmetrics
    beautifulsoup4
    jinja2
    slixmpp
    prometheus-client
    pyyaml
  ]);

  nativeCheckInputs = with python3Packages; [
    setuptools
    unittestCheckHook
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "prometheus_xmpp" ];

  passthru.tests = {
    binaryWorks = runCommand "${pname}-binary-test" { } ''
      # Running with --help to avoid it erroring due to a missing config file
      ${prometheus-xmpp-alerts}/bin/prometheus-xmpp-alerts --help | tee $out
      grep "usage: prometheus-xmpp-alerts" $out
    '';
  };

  meta = {
    description = "XMPP Web hook for Prometheus";
    homepage = "https://github.com/jelmer/prometheus-xmpp-alerts";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fpletz ];
    mainProgram = "prometheus-xmpp-alerts";
  };
}

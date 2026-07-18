{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
let
  version = "1.2.17";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "mktxp";

  src = fetchFromGitHub {
    owner = "akpw";
    repo = "mktxp";
    tag = "v${version}";
    hash = "sha256-SFnLLmtRF5JT1a78R0lwB+9XTJXW0fLyVJkN5xD3NIw=";
  };

  nativeBuildInputs = with python3Packages; [
    pypaInstallHook
    setuptoolsBuildHook
  ];

  dependencies = with python3Packages; [
    prometheus-client
    routeros-api
    configobj
    humanize
    texttable
    speedtest-cli
    waitress
    packaging
    pyyaml
  ];

  pyproject = false;

  meta = {
    description = "Prometheus Exporter for Mikrotik RouterOS devices";
    homepage = "https://github.com/akpw/mktxp";
    changelog = "https://github.com/akpw/mktxp/releases/tag/v${version}";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.BonusPlay ];
    platforms = lib.platforms.linux;
    mainProgram = "mktxp";
  };
}

{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  version = "2.4.1";
in
python3.pkgs.buildPythonApplication {
  inherit version;
  pname = "deluge-exporter";

  src = fetchFromGitHub {
    owner = "ibizaman";
    repo = "deluge_exporter";
    tag = "v${version}";
    hash = "sha256-1brLWx6IEGffcvHPCkz10k9GCNQIXXJ9PYZuEzlKHTA=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    deluge-client
    loguru
    prometheus-client
  ];

  pyproject = true;

  pythonImportsCheck = [
    "deluge_exporter"
  ];

  meta = {
    description = "Prometheus exporter for Deluge";
    homepage = "https://github.com/ibizaman/deluge_exporter";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ibizaman ];
    mainProgram = "deluge-exporter";
  };
}

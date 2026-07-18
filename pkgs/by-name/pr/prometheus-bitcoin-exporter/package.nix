{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "bitcoin-prometheus-exporter";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "jvstein";
    repo = "bitcoin-prometheus-exporter";
    tag = "v${version}";
    sha256 = "sha256-08QG/5Kj++rjWz7OciqKSJUk00lSJCbfB5XwwP+h4so=";
  };

  propagatedBuildInputs = with python3Packages; [
    prometheus-client
    python-bitcoinlib
    riprova
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp bitcoind-monitor.py $out/bin/

    mkdir -p $out/share/bitcoin-prometheus-exporter
    cp -r dashboard README.md $out/share/bitcoin-prometheus-exporter/
  '';

  # Copying bitcoind-monitor.py is enough.
  # The makefile builds docker containers.
  dontBuild = true;
  pyproject = false;

  meta = {
    description = "Prometheus exporter for Bitcoin Core nodes";
    homepage = "https://github.com/jvstein/bitcoin-prometheus-exporter";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mmilata ];
    platforms = lib.platforms.all;
    mainProgram = "bitcoind-monitor.py";
  };
}

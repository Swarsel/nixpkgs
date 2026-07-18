{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
  prometheus-nats-exporter,
  testers,
}:

buildGoModule rec {
  pname = "prometheus-nats-exporter";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "prometheus-nats-exporter";
    rev = "v${version}";
    sha256 = "sha256-siucc55qi1SS2R07xgxh25CWYjxncUqvzxo0XoIPyOo=";
  };

  vendorHash = "sha256-vRUPLKxwVTt3t8UpsSH4yMCIShpYhYI6j7AEmlyOADs=";

  preCheck = ''
    # Fix `insecure algorithm SHA1-RSA` problem
    export GODEBUG=x509sha1=1;
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  passthru = {
    tests = {
      prometheus-nats-exporter-version = testers.testVersion {
        package = prometheus-nats-exporter;
      };
    };

    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Exporter for NATS metrics";
    homepage = "https://github.com/nats-io/prometheus-nats-exporter";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bbigras ];
  };
}

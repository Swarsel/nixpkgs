{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go,
  prometheus-sql-exporter,
  testers,
}:

buildGoModule rec {
  pname = "sql_exporter";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "justwatchcom";
    repo = "sql_exporter";
    rev = "v${version}";
    sha256 = "sha256-fbPjUMSDNqF8TPnhRaTgIRsuTcHhaRkTND9KdCwaCUI=";
  };

  vendorHash = null;

  ldflags =
    let
      t = "github.com/prometheus/common/version";
    in
    [
      "-X ${t}.Version=${version}"
      "-X ${t}.Revision=${src.rev}"
      "-X ${t}.Branch=unknown"
      "-X ${t}.BuildUser=nix@nixpkgs"
      "-X ${t}.BuildDate=unknown"
      "-X ${t}.GoVersion=${lib.getVersion go}"
    ];

  passthru.tests.version = testers.testVersion {
    command = "sql_exporter -version";
    package = prometheus-sql-exporter;
  };

  meta = {
    description = "Flexible SQL exporter for Prometheus";
    homepage = "https://github.com/justwatchcom/sql_exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ justinas ];
    mainProgram = "sql_exporter";
  };
}

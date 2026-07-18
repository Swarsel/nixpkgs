{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nixosTests,
  varnish,
}:

buildGoModule rec {
  pname = "prometheus_varnish_exporter";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "jonnenauha";
    repo = "prometheus_varnish_exporter";
    rev = version;
    hash = "sha256-1sUzKLNkLP/eX0wYSestMAJpjAmX1iimjYoFYb6Mgpc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-P2fR0U2O0Y4Mci9jkAMb05WR+PrpuQ59vbLMG5b9KQI=";

  postInstall = ''
    wrapProgram $out/bin/prometheus_varnish_exporter \
      --prefix PATH : "${varnish}/bin"
  '';

  passthru.tests = { inherit (nixosTests.prometheus-exporters) varnish; };

  meta = {
    description = "Varnish exporter for Prometheus";
    homepage = "https://github.com/jonnenauha/prometheus_varnish_exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MostAwesomeDude ];
    mainProgram = "prometheus_varnish_exporter";
  };
}

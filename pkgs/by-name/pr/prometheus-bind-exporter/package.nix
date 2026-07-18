{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule rec {
  pname = "bind_exporter";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "prometheus-community";
    repo = "bind_exporter";
    rev = "v${version}";
    sha256 = "sha256-r1P+zy3iMgPmfvIBgycW8KS0gfNOxCT9YMmHdeY4uXA=";
  };

  vendorHash = "sha256-/fPj5LOe3QdnVPdtYdaqtnGMJ7/SZ458mpvjwO8TxEI=";
  passthru.tests = { inherit (nixosTests.prometheus-exporters) bind; };

  meta = {
    description = "Prometheus exporter for bind9 server";
    homepage = "https://github.com/digitalocean/bind_exporter";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rtreffer ];
    mainProgram = "bind_exporter";
  };
}

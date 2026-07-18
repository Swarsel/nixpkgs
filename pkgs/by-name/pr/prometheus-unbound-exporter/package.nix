{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

let
  version = "0.6.0";
in
buildGoModule {
  inherit version;
  pname = "unbound_exporter";

  src = fetchFromGitHub {
    owner = "letsencrypt";
    repo = "unbound_exporter";
    tag = "v${version}";
    hash = "sha256-XsiQGVYBEXM8DQtQWEA2wk/19TGGZaIBt7Vc4HHfIBY=";
  };

  vendorHash = "sha256-2M7s9YPAFxCQcIgF+HDKu6kztHBvbl/S2BmaBngeBFI=";

  passthru.tests = {
    inherit (nixosTests.prometheus-exporters) unbound;
  };

  meta = {
    description = "Prometheus exporter for Unbound DNS resolver";
    homepage = "https://github.com/letsencrypt/unbound_exporter/tree/main";
    changelog = "https://github.com/letsencrypt/unbound_exporter/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "unbound_exporter";
  };
}

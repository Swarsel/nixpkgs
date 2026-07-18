{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule rec {
  pname = "lndmon";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "lndmon";
    rev = "v${version}";
    hash = "sha256-PzmDotyuG8Fgkr6SlBWofqQamDG39v65fFjRUKjIWWM=";
  };

  vendorHash = "sha256-6wBA9OZcjGsbIgWzMXlcT2571sFvtYqIsHRfLAz/o60=";
  # Irrelevant tools dependencies.
  excludedPackages = [ "./tools" ];
  passthru.tests = { inherit (nixosTests.prometheus-exporters) lnd; };

  meta = {
    description = "Prometheus exporter for lnd (Lightning Network Daemon)";
    homepage = "https://github.com/lightninglabs/lndmon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mmilata ];
    mainProgram = "lndmon";
  };
}

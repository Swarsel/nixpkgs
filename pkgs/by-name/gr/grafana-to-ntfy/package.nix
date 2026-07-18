{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "grafana-to-ntfy";
  version = "2026.5.2";

  src = fetchFromGitHub {
    owner = "kittyandrew";
    repo = "grafana-to-ntfy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lbzo/+dQG5u+LfbnhUEL4KDjkod1kCWQ+m2Fsa2VrFo=";
  };

  cargoHash = "sha256-vXicD4jUgaioK09oFBn3BgWDR3bzM7m5KStHr4Wqmfk=";
  # No unit tests; all testing is NixOS VM-based integration tests
  doCheck = false;

  passthru = {
    tests.grafana-to-ntfy = nixosTests.grafana-to-ntfy;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Bridge to forward Grafana and Prometheus Alertmanager alerts to ntfy.sh";
    homepage = "https://github.com/kittyandrew/grafana-to-ntfy";
    changelog = "https://github.com/kittyandrew/grafana-to-ntfy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ kittyandrew ];
    platforms = lib.platforms.linux;
    mainProgram = "grafana-to-ntfy";
  };
})

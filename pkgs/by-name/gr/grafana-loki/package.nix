{
  lib,
  fetchFromGitHub,
  buildGoModule,
  grafana-loki,
  nix-update-script,
  nixosTests,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "grafana-loki";
  version = "3.7.3";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "loki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2dqwnM2+9+P/ZIiz5Z9JPN9WicHLRzq9xn6jG1OBqLs=";
  };

  vendorHash = null;

  ldflags =
    let
      t = "github.com/grafana/loki/v3/pkg/util/build";
    in
    [
      "-s"
      "-w"
      "-X ${t}.Version=${finalAttrs.version}"
      "-X ${t}.BuildUser=nix@nixpkgs"
      "-X ${t}.BuildDate=unknown"
      "-X ${t}.Branch=unknown"
      "-X ${t}.Revision=unknown"
    ];

  subPackages = [
    # TODO split every executable into its own package
    "cmd/loki"
    "cmd/loki-canary"
    "cmd/logcli"
    "cmd/lokitool"
  ];

  passthru = {
    tests = {
      inherit (nixosTests) loki;

      version = testers.testVersion {
        command = "loki --version";
        package = grafana-loki;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Like Prometheus, but for logs";
    homepage = "https://grafana.com/oss/loki/";
    changelog = "https://github.com/grafana/loki/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      agpl3Only
      asl20
    ];

    maintainers = with lib.maintainers; [
      globin
      mmahut
      emilylange
      ryan4yin
    ];

    mainProgram = "loki";
  };
})

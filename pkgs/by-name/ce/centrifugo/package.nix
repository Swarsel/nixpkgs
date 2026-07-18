{
  lib,
  fetchFromGitHub,
  buildGoModule,
  centrifugo,
  nix-update-script,
  nixosTests,
  testers,
}:
let
  # Inspect build flags with `go version -m centrifugo`.
  statsEndpoint = "https://graphite-prod-01-eu-west-0.grafana.net/graphite/metrics,https://stats.centrifugal.dev/usage";
  statsToken =
    "425599:eyJrIjoi"
    + "OWJhMTcyZGNjN2FkYjEzM2E1OTQwZjIyMTU3MTBjMjUyYzAyZWE2MSIsIm4iOiJVc2FnZSBTdGF0cyIsImlkIjo2NDUzOTN9";
in
buildGoModule (finalAttrs: {
  pname = "centrifugo";
  version = "6.6.2";

  src = fetchFromGitHub {
    owner = "centrifugal";
    repo = "centrifugo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-V67riIkwBKz4YvCo6PJS3jrVl3Q6DE9ewEzzHPi7YFE=";
  };

  vendorHash = "sha256-K/90YrXkwiDt9Zm6h5nVo34WjtQQKBCNigJguwAdW5E=";

  excludedPackages = [
    "./internal/gen/api"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/centrifugal/centrifugo/v6/internal/build.Version=${finalAttrs.version}"
    "-X=github.com/centrifugal/centrifugo/v6/internal/build.UsageStatsEndpoint=${statsEndpoint}"
    "-X=github.com/centrifugal/centrifugo/v6/internal/build.UsageStatsToken=${statsToken}"
  ];

  passthru = {
    tests = {
      inherit (nixosTests) centrifugo;

      version = testers.testVersion {
        version = "v${finalAttrs.version}";
        command = "centrifugo version";
        package = centrifugo;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Scalable real-time messaging server";
    homepage = "https://centrifugal.dev";
    changelog = "https://github.com/centrifugal/centrifugo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = [
      lib.maintainers.tie
      lib.maintainers.valodim
    ];

    mainProgram = "centrifugo";
  };
})

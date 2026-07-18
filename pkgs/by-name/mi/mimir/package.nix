{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
}:
buildGoModule (finalAttrs: {
  pname = "mimir";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "mimir";
    rev = "mimir-${finalAttrs.version}";
    hash = "sha256-8GvpmCanVlsObH1mwPA/TsHzNp3f0hzF7fURIDHy/DU=";
  };

  vendorHash = null;

  ldflags =
    let
      t = "github.com/grafana/mimir/pkg/util/version";
    in
    [
      "-s"
      "-w"
      "-X ${t}.Version=${finalAttrs.version}"
      "-X ${t}.Revision=unknown"
      "-X ${t}.Branch=unknown"
    ];

  subPackages = [
    "cmd/mimir"
    "cmd/mimirtool"
  ]
  ++ (map (pathName: "tools/${pathName}") [
    "compaction-planner"
    "copyblocks"
    "copyprefix"
    "delete-objects"
    "list-deduplicated-blocks"
    "listblocks"
    "mark-blocks"
    "splitblocks"
    "tenant-injector"
    "undelete-blocks"
  ]);

  passthru = {
    tests = {
      inherit (nixosTests) mimir;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "mimir-(3\\.[0-9.]+)"
      ];
    };
  };

  meta = {
    description = "Grafana Mimir provides horizontally scalable, highly available, multi-tenant, long-term storage for Prometheus. ";
    homepage = "https://github.com/grafana/mimir";
    changelog = "https://github.com/grafana/mimir/releases/tag/mimir-${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      happysalada
      bryanhonof
      adamcstephens
    ];
  };
})

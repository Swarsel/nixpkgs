{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  withServer ? true,
  withVlAgent ? false,
}:

buildGoModule (finalAttrs: {
  pname = "VictoriaLogs";
  version = "1.51.0";

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaLogs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8rUDMV7bxMxyU0NYIMFSqGzSMwGogKFDliGXf4VSoCI=";
  };

  postPatch = ''
    # Relax go version to major.minor
    sed -i -E 's/^(go[[:space:]]+[[:digit:]]+\.[[:digit:]]+)\.[[:digit:]]+$/\1/' go.mod
    sed -i -E 's/^(## explicit; go[[:space:]]+[[:digit:]]+\.[[:digit:]]+)\.[[:digit:]]+$/\1/' vendor/modules.txt
  '';

  vendorHash = null;
  env.CGO_ENABLED = 0;
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=${finalAttrs.version}"
  ];

  subPackages =
    lib.optionals withServer [
      "app/victoria-logs"
      "app/vlinsert"
      "app/vlselect"
      "app/vlstorage"
      "app/vlogsgenerator"
      "app/vlogscli"
    ]
    ++ lib.optionals withVlAgent [ "app/vlagent" ];

  passthru = {
    tests = lib.recurseIntoAttrs nixosTests.victorialogs;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "User friendly log database from VictoriaMetrics";
    homepage = "https://docs.victoriametrics.com/victorialogs/";
    changelog = "https://github.com/VictoriaMetrics/VictoriaLogs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      marie
      shawn8901
    ];

    mainProgram = "victoria-logs";
  };
})

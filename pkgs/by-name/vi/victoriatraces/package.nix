{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  nix-update-script,
  nixosTests,
  withServer ? true,
  withVtGen ? false,
  withVtInsert ? false,
  withVtSelect ? false,
  withVtStorage ? false,
}:

buildGo126Module (finalAttrs: {
  pname = "VictoriaTraces";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaTraces";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tIYiyaYHJzlOHeGSu+DlLTvxc5SrVWA76pMTCrJtwbE=";
  };

  vendorHash = null;
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/VictoriaMetrics/VictoriaTraces/lib/buildinfo.Version=${finalAttrs.version}"
  ];

  subPackages =
    lib.optionals withServer [ "app/victoria-traces" ]
    ++ lib.optionals withVtInsert [ "app/vtinsert" ]
    ++ lib.optionals withVtSelect [ "app/vtselect" ]
    ++ lib.optionals withVtStorage [ "app/vtstorage" ]
    ++ lib.optionals withVtGen [ "app/vtgen" ];

  passthru = {
    tests = lib.recurseIntoAttrs nixosTests.victoriatraces;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast open-source observability solution for distributed traces";
    homepage = "https://docs.victoriametrics.com/victoriatraces/";
    changelog = "https://github.com/VictoriaMetrics/VictoriaTraces/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cmacrae
      ma27
    ];

    mainProgram = "victoria-traces";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "cortex-tools";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "grafana-cold-storage";
    repo = "cortex-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+GWUC+lnCn5Nw2WytSvW/UsIMmMelCCsnKdBCHuue24=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  env.CGO_ENABLED = 0;
  doCheck = true;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cortextool \
      --bash <($out/bin/cortextool --completion-script-bash) \
      --zsh <($out/bin/cortextool --completion-script-zsh)

    $out/bin/cortextool --help-man > cortextool.1
    installManPage cortextool.1
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X github.com/grafana-cold-storage/cortex-tools/pkg/version.Version=${finalAttrs.src.tag}"
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/benchtool"
    "cmd/cortextool"
    "cmd/e2ealerting"
    "cmd/logtool"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools used for interacting with Cortex, a Prometheus-compatible server";

    longDescription = ''
      Tools used for interacting with Cortex, a horizontally scalable, highly available, multi-tenant, long term Prometheus server:

      - benchtool: A powerful YAML driven tool for benchmarking Cortex write and query API.
      - cortextool: Interacts with user-facing Cortex APIs and backend storage components.
      - logtool: Tool which parses Cortex query-frontend logs and formats them for easy analysis.
      - e2ealerting: Tool that helps measure how long an alert takes from scrape of sample to Alertmanager notification delivery.
    '';

    homepage = "https://github.com/grafana-cold-storage/cortex-tools";
    changelog = "https://github.com/grafana-cold-storage/cortex-tools/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ videl ];
    platforms = lib.platforms.linux ++ lib.platforms.windows ++ lib.platforms.darwin;
    mainProgram = "cortextool";
  };
})

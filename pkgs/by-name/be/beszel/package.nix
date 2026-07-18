{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo126Module,
  buildNpmPackage,
  fetchpatch,
  nix-update-script,
  nixosTests,
}:
buildGo126Module (finalAttrs: {
  pname = "beszel";
  version = "0.18.7";

  src = fetchFromGitHub {
    owner = "henrygd";
    repo = "beszel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pVZ1ru9++BypZ3EwoE8clqJowXj1/CMiJxKaC+UY9VE=";
  };

  patches = [
    # https://github.com/NixOS/nixpkgs/pull/513197
    (fetchpatch {
      hash = "sha256-voIT9b14pgfhnbJrqgoIbQtwZPU1JF0fblybjG9mzvM=";
      name = "fix-updater-after-system-manager-shutdown.patch";
      url = "https://github.com/henrygd/beszel/commit/c538d1de1cf3f4664a2d98086341884a217846e7.patch";
    })
  ];

  vendorHash = "sha256-TVpZbK9V9/GqpVFcjF7QGD5XJJHzRgjVXZOImHQTR1k=";

  preBuild = ''
    mkdir -p internal/site/dist
    cp -r ${finalAttrs.webui}/* internal/site/dist
  '';

  checkFlags =
    let
      skippedTests = [
        "TestCollectorStartHelpers/nvtop_collector"
        "TestApiRoutesAuthentication/GET_/update_-_shouldn't_exist_without_CHECK_UPDATES_env_var"
        "TestConfigSyncWithTokens"
        # This subtest assumes enough host CPUs for an 8s CPU delta over 1s to stay below 100%.
        "TestServiceUpdateCPUPercent/subsequent_call_calculates_CPU_percentage"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        "TestCollectorStartHelpers/nvidia-smi_collector"
        "TestCollectorStartHelpers/rocm-smi_collector"
        "TestCollectorStartHelpers/tegrastats_collector"
        "TestNewGPUManagerPriorityNvtopFallback"
        "TestNewGPUManagerPriorityMixedCollectors"
        "TestNewGPUManagerPriorityNvmlFallbackToNvidiaSmi"
        "TestNewGPUManagerConfiguredCollectorsMustStart"
        "TestNewGPUManagerConfiguredNvmlBypassesCapabilityGate"
        "TestNewGPUManagerJetsonIgnoresCollectorConfig"
      ];
    in
    [
      "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"
      "-tags=testing"
    ];

  postInstall = ''
    mv $out/bin/agent $out/bin/beszel-agent
    mv $out/bin/hub $out/bin/beszel-hub
  '';

  __darwinAllowLocalNetworking = true;

  webui = buildNpmPackage {
    inherit (finalAttrs)
      pname
      version
      src
      meta
      ;

    npmDepsHash = "sha256-mYAD8FrQwa+F/VgGxFpe8vqucfZaM0PmY+gJJqw1IKk=";

    buildPhase = ''
      runHook preBuild

      npx lingui extract --overwrite
      npx lingui compile
      node --max_old_space_size=1024000 ./node_modules/vite/bin/vite.js build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out

      runHook postInstall
    '';

    npmFlags = [ "--legacy-peer-deps" ];
    sourceRoot = "${finalAttrs.src.name}/internal/site";
  };

  passthru = {
    tests.nixos = nixosTests.beszel;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "webui"
      ];
    };
  };

  meta = {
    description = "Lightweight server monitoring hub with historical data, docker stats, and alerts";
    homepage = "https://github.com/henrygd/beszel";
    changelog = "https://github.com/henrygd/beszel/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bot-wxt1221
      arunoruto
      BonusPlay
    ];
  };
})

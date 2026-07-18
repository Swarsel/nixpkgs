{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  buildGoModule,
  callPackage,
  nix-update-script,
  nixosTests,
  versionCheckHook,
}:

let
  canExecute = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
in
buildGoModule (finalAttrs: {
  pname = "llama-swap";
  version = "224";

  src = fetchFromGitHub {
    owner = "mostlygeek";
    repo = "llama-swap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IblAaM9FBdI2Y9rg36SWpclQ0jV6Y93RC+N+cXWEO94=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # '0000-00-00T00:00:00Z'
      date -u -d "@$(git log -1 --pretty=%ct)" "+'%Y-%m-%dT%H:%M:%SZ'" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  outputs = [
    "out"
    "wol" # wake on lan proxy
  ];

  postPatch = ''
    substituteInPlace internal/process/process_command_forking_test.go \
      --replace "#!/bin/bash" "#!${lib.getExe bash}"
  '';

  nativeBuildInputs = [
    versionCheckHook
  ];

  vendorHash = "sha256-b+RreafBMCWT/jbWTlXaiDRzA4DRe76WaCEbrfRxV/4=";

  preBuild = ''
    # ldflags based on metadata from git and source
    ldflags+=" -X main.commit=$(cat COMMIT)"
    ldflags+=" -X main.date=$(cat SOURCE_DATE_EPOCH)"

    # copy for go:embed in internal/server/ui_embed.go
    cp -r ${finalAttrs.passthru.ui}/ui_dist internal/server/
  '';

  # some tests expect to execute `simple-something` and proxy/helpers_test.go
  # checks the file exists
  doCheck = canExecute;

  checkFlags =
    let
      skippedTests = lib.optionals (stdenv.hostPlatform.isDarwin) [
        # Fail only on *-darwin intermittently
        # https://github.com/mostlygeek/llama-swap/issues/320
        "TestProcess_AutomaticallyStartsUpstream"
        "TestProcess_WaitOnMultipleStarts"
        "TestProcess_BrokenModelConfig"
        "TestProcess_UnloadAfterTTL"
        "TestProcess_LowTTLValue"
        "TestProcess_HTTPRequestsHaveTimeToFinish"
        "TestProcess_SwapState"
        "TestProcess_ShutdownInterruptsHealthCheck"
        "TestProcess_ExitInterruptsHealthCheck"
        "TestProcess_ConcurrencyLimit"
        "TestProcess_StopImmediately"
        "TestProcess_ForceStopWithKill"
        "TestProcess_StopCmd"
        "TestProcess_EnvironmentSetCorrectly"
        "TestProcess_ReverseProxyPanicIsHandled"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    mkdir build
    ln -s "$GOPATH/bin/simple-responder" "./build/simple-responder_''${GOOS}_''${GOARCH}"
  '';

  postCheck = ''
    rm "$GOPATH/bin/simple-responder"
  '';

  postInstall = ''
    install -Dm444 -t "$out/share/llama-swap" config.example.yaml
    mkdir -p "$wol/bin"
    mv "$out/bin/wol-proxy" "$wol/bin/"
  '';

  doInstallCheck = true;
  # required for testing
  __darwinAllowLocalNetworking = true;

  excludedPackages = [
    # regression testing tool
    "misc/process-cmd-test"
    # benchmark/regression testing tool
    "misc/benchmark-chatcompletion"
  ]
  ++ lib.optionals (!canExecute) [
    # some tests expect to execute `simple-something`; if it can't be executed
    # it's unneeded
    "misc/simple-responder"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "-version";
  passthru.tests.nixos = nixosTests.llama-swap;
  passthru.ui = callPackage ./ui.nix { llama-swap = finalAttrs.finalPackage; };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "ui"
    ];
  };

  meta = {
    description = "Model swapping for llama.cpp (or any local OpenAPI compatible server)";

    longDescription = ''
      llama-swap is a light weight, transparent proxy server that provides
      automatic model swapping to llama.cpp's server.

      When a request is made to an OpenAI compatible endpoint, llama-swap will
      extract the `model` value and load the appropriate server configuration to
      serve it. If the wrong upstream server is running, it will be replaced
      with the correct one. This is where the "swap" part comes in. The upstream
      server is automatically swapped to the correct one to serve the request.

      In the most basic configuration llama-swap handles one model at a time.
      For more advanced use cases, the `groups` feature allows multiple models
      to be loaded at the same time. You have complete control over how your
      system resources are used.
    '';

    homepage = "https://github.com/mostlygeek/llama-swap";
    changelog = "https://github.com/mostlygeek/llama-swap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jk
      podium868909
    ];

    mainProgram = "llama-swap";
  };
})

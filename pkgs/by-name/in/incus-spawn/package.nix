{
  lib,
  fetchurl,
  autoPatchelfHook,
  common-updater-scripts,
  curl,
  incus-spawn,
  installShellFiles,
  jq,
  stdenvNoCC,
  testers,
  writeShellScript,
  zlib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "incus-spawn";
  version = "0.2.7";

  src =
    finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    zlib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/isx
    install -Dm755 ${finalAttrs.passthru.git-remote-isx} $out/bin/git-remote-isx

    runHook postInstall
  '';

  # Generate shell completions after autoPatchelfHook has patched the ELF binary.
  # On Linux, autoPatchelfHook runs in postFixupHooks so we use installCheckPhase
  # which runs after fixup is fully complete. On Darwin no patching is needed but
  # we keep the same phase for consistency.
  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;

  installCheckPhase = ''
    runHook preInstallCheck

    installShellCompletion --cmd isx \
      --bash <($out/bin/isx completion bash) \
      --zsh <($out/bin/isx completion zsh) \
      --fish <($out/bin/isx completion fish)

    runHook postInstallCheck
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontStrip = stdenvNoCC.hostPlatform.isDarwin;
  dontUnpack = true;

  passthru = {
    git-remote-isx = fetchurl {
      hash = "sha256-I9zmdLzO7VcfLHdgFD2Lvwiq4fkDw885j1JWsL8c+hA=";
      url = "https://github.com/Sanne/incus-spawn/releases/download/v${finalAttrs.version}/git-remote-isx";
    };

    sources = {
      "aarch64-darwin" = fetchurl {
        hash = "sha256-Uv0v7LxIcB0oNEnW1vK9Iy6MOwxoUeqtszGfsS5wt6k=";
        url = "https://github.com/Sanne/incus-spawn/releases/download/v${finalAttrs.version}/incus-spawn-macos-aarch64";
      };

      "aarch64-linux" = fetchurl {
        hash = "sha256-Y7OaNgQKAN/HVt75+tawrCtkyZdAHfAiUxx2a0eD5P8=";
        url = "https://github.com/Sanne/incus-spawn/releases/download/v${finalAttrs.version}/incus-spawn-linux-aarch64";
      };

      "x86_64-linux" = fetchurl {
        hash = "sha256-jgdNuVfVshbg8piAGGpIy4cnJj5glbsGqOENDBoqpzI=";
        url = "https://github.com/Sanne/incus-spawn/releases/download/v${finalAttrs.version}/incus-spawn-linux-amd64";
      };
    };

    tests.version = testers.testVersion {
      command = "isx --version";
      package = incus-spawn;
    };

    updateScript = writeShellScript "update-incus-spawn" ''
      set -o errexit
      export PATH="${
        lib.makeBinPath [
          curl
          jq
          common-updater-scripts
        ]
      }"
      NEW_VERSION=$(curl --silent https://api.github.com/repos/Sanne/incus-spawn/releases/latest | jq '.tag_name | ltrimstr("v")' --raw-output)
      if [[ "${finalAttrs.version}" = "$NEW_VERSION" ]]; then
          echo "incus-spawn is already at $NEW_VERSION"
          exit 0
      fi
      update-source-version incus-spawn "$NEW_VERSION" --source-key="git-remote-isx"
      for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
        update-source-version incus-spawn "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "CLI tool for managing isolated Incus development environments";

    longDescription = ''
      incus-spawn (isx) creates isolated Linux development environments using
      Incus system containers with copy-on-write branching, a MITM TLS proxy
      for credential isolation, and an interactive TUI.
    '';

    homepage = "https://github.com/Sanne/incus-spawn";
    changelog = "https://github.com/Sanne/incus-spawn/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      galder
    ];

    platforms = lib.attrNames finalAttrs.passthru.sources;
    mainProgram = "isx";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  buildPackages,
  installShellFiles,
  makeWrapper,
  python3,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "kluctl";
  version = "2.28.2";

  src = fetchFromGitHub {
    owner = "kluctl";
    repo = "kluctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Adh2n8aE+DEBY1MC4laVPDdr5dq6FKSMEFLjbs74D4c=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-cQJRU3vL5wJ0dgYMtN4qFdvJyp367I4N7GM6PhRvW0I=";

  preBuild =
    let
      webui = buildNpmPackage {
        inherit (finalAttrs) version src;
        pname = "kluctl-webui";
        npmDepsHash = "sha256-e5Ic3W1UPQn/2ggaYez7G7exXNZA6BobP4BTM6B6rlI=";

        installPhase = ''
          mkdir -p $out
          cp -r build $out/
        '';

        npmBuildScript = "build";
        sourceRoot = "source/pkg/webui/ui";
      };
    in
    ''
      rm -rf pkg/webui/ui/build
      cp -r ${webui}/build pkg/webui/ui/build
    '';

  # Depends on docker
  doCheck = false;

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      mv $out/bin/{cmd,kluctl}
      wrapProgram $out/bin/kluctl \
        --set KLUCTL_USE_SYSTEM_PYTHON 1 \
        --prefix PATH : '${lib.makeBinPath [ python3 ]}'
      installShellCompletion --cmd kluctl \
        --bash <(${emulator} $out/bin/kluctl completion bash) \
        --fish <(${emulator} $out/bin/kluctl completion fish) \
        --zsh  <(${emulator} $out/bin/kluctl completion zsh)
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-X main.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd" ];

  meta = {
    description = "Missing glue to put together large Kubernetes deployments";
    homepage = "https://kluctl.io/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      sikmir
      netthier
    ];

    mainProgram = "kluctl";
  };
})

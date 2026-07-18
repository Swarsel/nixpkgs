{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildkit,
  cni-plugins,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  extraPackages ? [ ],
}:

buildGoModule (finalAttrs: {
  pname = "nerdctl";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "containerd";
    repo = "nerdctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qg00iJUVCzza6ppd5ut7YLA97YYfwXSw+0O+yNHZUN8=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  vendorHash = "sha256-BmlcW3svWyK55rduTiPOZbIN9bLc+v9yvzlDwrZPniA=";
  # Many checks require a containerd socket and running nerdctl after it's built
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/nerdctl \
      --prefix PATH : "${lib.makeBinPath ([ buildkit ] ++ extraPackages)}" \
      --prefix CNI_PATH : "${cni-plugins}/bin"

    installShellCompletion --cmd nerdctl \
      --bash <($out/bin/nerdctl completion bash) \
      --fish <($out/bin/nerdctl completion fish) \
      --zsh <($out/bin/nerdctl completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  # testing framework which we don't need and can't be build as it is an extra go application
  excludedPackages = [ "mod/tigron" ];

  ldflags =
    let
      t = "github.com/containerd/nerdctl/v${lib.versions.major finalAttrs.version}/pkg/version";
    in
    [
      "-s"
      "-w"
      "-X ${t}.Version=v${finalAttrs.version}"
      "-X ${t}.Revision=<unknown>"
    ];

  versionCheckKeepEnvironment = [ "HOME" ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^v([0-9.]+)$" ];
    };
  };

  meta = {
    description = "Docker-compatible CLI for containerd";
    homepage = "https://github.com/containerd/nerdctl/";
    changelog = "https://github.com/containerd/nerdctl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      developer-guy
      jk
      miniharinn
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nerdctl";
  };
})

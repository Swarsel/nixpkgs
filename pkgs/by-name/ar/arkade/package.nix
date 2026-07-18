{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "arkade";
  version = "0.11.113";

  src = fetchFromGitHub {
    owner = "alexellis";
    repo = "arkade";
    tag = finalAttrs.version;
    hash = "sha256-8T7gYaT52L4Xnbuxvi9GayQ1qfI5U2cphSIkRGqx5Go=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd arkade \
      --bash <($out/bin/arkade completion bash) \
      --zsh <($out/bin/arkade completion zsh) \
      --fish <($out/bin/arkade completion fish)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/alexellis/arkade/pkg.GitCommit=ref/tags/${finalAttrs.version}"
    "-X github.com/alexellis/arkade/pkg.Version=${finalAttrs.version}"
  ];

  # Exclude pkg/get: tests downloading of binaries which fail when sandbox=true
  subPackages = [
    "."
    "cmd"
    "pkg/apps"
    "pkg/archive"
    "pkg/config"
    "pkg/env"
    "pkg/helm"
    "pkg/k8s"
    "pkg/types"
  ];

  meta = {
    description = "Open Source Kubernetes Marketplace";
    homepage = "https://github.com/alexellis/arkade";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      welteki
      techknowlogick
      qjoly
    ];

    mainProgram = "arkade";
  };
})

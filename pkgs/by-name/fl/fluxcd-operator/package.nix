{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "fluxcd-operator";
  version = "0.54.0";

  src = fetchFromGitHub {
    owner = "controlplaneio-fluxcd";
    repo = "flux-operator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bxzqm4I+wTj1k8ppa4cohsowmgc7H76EuHCYlCiJ5Qk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-DW+dnakqnpSiV7MlzshGEzoy3Osv93dAsJYe4cR0sJ4=";
  env.CGO_ENABLED = 0;
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    mv $out/bin/cli $out/bin/flux-operator
    for shell in bash fish zsh; do
      installShellCompletion --cmd flux-operator \
        --$shell <($out/bin/flux-operator completion $shell)
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.VERSION=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/cli" ];
  versionCheckProgram = "${placeholder "out"}/bin/flux-operator";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Kubernetes controller for managing the lifecycle of Flux CD";

    longDescription = ''
      The Flux Operator is a Kubernetes CRD controller that manages the lifecycle of CNCF Flux CD
      and the ControlPlane enterprise distribution. The operator extends Flux with self-service
      capabilities and preview environments for GitLab and GitHub pull requests testing.
    '';

    homepage = "https://fluxcd.control-plane.io/operator/";
    changelog = "https://github.com/controlplaneio-fluxcd/flux-operator/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      mattfield
      stealthybox
    ];

    mainProgram = "flux-operator";
    downloadPage = "https://github.com/controlplaneio-fluxcd/flux-operator";
  };
})

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
  pname = "fluxcd-operator-mcp";
  version = "0.52.0";

  src = fetchFromGitHub {
    owner = "controlplaneio-fluxcd";
    repo = "flux-operator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l+IJtFmVR3WZaFW4aaYjirTqj+X1FGLAVgbA21MHO1k=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-DW+dnakqnpSiV7MlzshGEzoy3Osv93dAsJYe4cR0sJ4=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/mcp $out/bin/flux-operator-mcp
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd flux-operator-mcp \
        --$shell <($out/bin/flux-operator-mcp completion $shell)
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.VERSION=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/mcp" ];
  versionCheckProgram = "${placeholder "out"}/bin/flux-operator-mcp";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Kubernetes controller for managing the lifecycle of Flux CD";

    longDescription = ''
      The Flux Operator is a Kubernetes CRD controller that manages the lifecycle of CNCF Flux CD
      and the ControlPlane enterprise distribution. The operator extends Flux with self-service
      capabilities and preview environments for GitLab and GitHub pull requests testing.
    '';

    homepage = "https://fluxcd.control-plane.io/mcp/";
    changelog = "https://github.com/controlplaneio-fluxcd/flux-operator/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      mattfield
      stealthybox
    ];

    mainProgram = "flux-operator-mcp";
    downloadPage = "https://github.com/controlplaneio-fluxcd/flux-operator";
  };
})

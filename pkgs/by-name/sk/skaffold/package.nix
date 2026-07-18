{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "skaffold";
  version = "2.23.0";

  src = fetchFromGitHub {
    owner = "GoogleContainerTools";
    repo = "skaffold";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mFJOveUkOJC7bIzxrjQgDKhCf0WvOTgSDqBSIVgZZzw=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = null;

  postInstall = ''
    wrapProgram $out/bin/skaffold --set SKAFFOLD_UPDATE_CHECK false

    installShellCompletion --cmd skaffold \
      --bash <($out/bin/skaffold completion bash) \
      --zsh <($out/bin/skaffold completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/skaffold version | grep ${finalAttrs.version} > /dev/null
  '';

  ldflags =
    let
      t = "github.com/GoogleContainerTools/skaffold/v2/pkg/skaffold";
    in
    [
      "-s"
      "-w"
      "-X ${t}/version.version=v${finalAttrs.version}"
      "-X ${t}/version.gitCommit=${finalAttrs.src.rev}"
      "-X ${t}/version.buildDate=unknown"
    ];

  subPackages = [ "cmd/skaffold" ];

  meta = {
    description = "Easy and Repeatable Kubernetes Development";

    longDescription = ''
      Skaffold is a command line tool that facilitates continuous development for Kubernetes applications.
      You can iterate on your application source code locally then deploy to local or remote Kubernetes clusters.
      Skaffold handles the workflow for building, pushing and deploying your application.
      It also provides building blocks and describe customizations for a CI/CD pipeline.
    '';

    homepage = "https://skaffold.dev/";
    changelog = "https://github.com/GoogleContainerTools/skaffold/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      vdemeester
    ];

    mainProgram = "skaffold";
  };
})

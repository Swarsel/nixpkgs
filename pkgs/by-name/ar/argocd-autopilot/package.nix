{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "argocd-autopilot";
  version = "0.4.20";

  src = fetchFromGitHub {
    owner = "argoproj-labs";
    repo = "argocd-autopilot";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-JLh41ZWiDcDrUtd8d+Ak5TFca4L6VHzUguS55P9lmj0=";
  };

  vendorHash = "sha256-Ur0BfIg4lZakjx01UOL4n5/O1yjTJJcGuDxWVDqUOyY=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 "$GOPATH/bin/cmd" -T $out/bin/argocd-autopilot

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/argocd-autopilot version | grep ${finalAttrs.src.rev} > /dev/null
  '';

  ldflags =
    let
      package_url = "github.com/argoproj-labs/argocd-autopilot/pkg/store";
    in
    [
      "-s"
      "-w"
      "-X ${package_url}.binaryName=argocd-autopilot"
      "-X ${package_url}.version=${finalAttrs.src.rev}"
      "-X ${package_url}.buildDate=unknown"
      "-X ${package_url}.gitCommit=${finalAttrs.src.rev}"
      "-X ${package_url}.installationManifestsURL=github.com/argoproj-labs/argocd-autopilot/manifests/base?ref=${finalAttrs.src.rev}"
      "-X ${package_url}.installationManifestsNamespacedURL=github.com/argoproj-labs/argocd-autopilot/manifests/insecure?ref=${finalAttrs.src.rev}"
    ];

  proxyVendor = true;
  subPackages = [ "cmd" ];

  meta = {
    description = "ArgoCD Autopilot";
    homepage = "https://argocd-autopilot.readthedocs.io/en/stable/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      sagikazarmark
    ];

    mainProgram = "argocd-autopilot";
    downloadPage = "https://github.com/argoproj-labs/argocd-autopilot";
  };
})

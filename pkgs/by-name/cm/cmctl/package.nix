{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "cmctl";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "cert-manager";
    repo = "cmctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TFVGyb09+QDcRy1y6ilQ0A2IJ13ZQOZJ+X+habgAG6U=";
  };

  # integration tests require running etcd, kubernetes
  postPatch = ''
    rm -r test/integration
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-u7r+RIYleY7Ymtc/ZnQSkGADxBmjqHdQV2M0myV+UUg=";
  # Trusted by this computer: no: x509: “cert-manager” certificate is not
  # trusted
  doCheck = !stdenv.hostPlatform.isDarwin;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cmctl \
        --bash <($out/bin/cmctl completion bash) \
        --fish <($out/bin/cmctl completion fish) \
        --zsh <($out/bin/cmctl completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/cert-manager/cert-manager/pkg/util.AppVersion=v${finalAttrs.version}"
    "-X github.com/cert-manager/cert-manager/pkg/util.AppGitCommit=${finalAttrs.src.rev}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line utility to interact with a cert-manager instalation on Kubernetes";

    longDescription = ''
      cert-manager adds certificates and certificate issuers as resource types
      in Kubernetes clusters, and simplifies the process of obtaining, renewing
      and using those certificates.

      It can issue certificates from a variety of supported sources, including
      Let's Encrypt, HashiCorp Vault, and Venafi as well as private PKI, and it
      ensures certificates remain valid and up to date, attempting to renew
      certificates at an appropriate time before expiry.

      cmctl is a command line tool to help you manage cert-manager and its
      resources inside your Kubernetes cluster.
    '';

    homepage = "https://cert-manager.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ joshvanl ];
    mainProgram = "cmctl";
    downloadPage = "https://github.com/cert-manager/cmctl";
  };
})

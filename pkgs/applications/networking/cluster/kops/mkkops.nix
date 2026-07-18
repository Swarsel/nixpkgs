{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:
lib.extendMkDerivation {
  constructDrv = buildGoModule;

  excludeDrvArgNames = [
    "sha256"
    "rev"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      sha256,
      version,
      rev ? version,
      ...
    }:
    {
      pname = "kops";

      src = fetchFromGitHub {
        inherit sha256;
        owner = "kubernetes";
        repo = "kops";
        rev = rev;
      };

      nativeBuildInputs = [ installShellFiles ];
      vendorHash = null;
      doCheck = false;

      postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
        installShellCompletion --cmd kops \
          --bash <($GOPATH/bin/kops completion bash) \
          --fish <($GOPATH/bin/kops completion fish) \
          --zsh <($GOPATH/bin/kops completion zsh)
      '';

      ldflags = [
        "-s"
        "-w"
        "-X k8s.io/kops.Version=${finalAttrs.version}"
        "-X k8s.io/kops.GitVersion=${finalAttrs.version}"
      ];

      subPackages = [ "cmd/kops" ];

      meta = {
        description = "Easiest way to get a production Kubernetes up and running";
        homepage = "https://github.com/kubernetes/kops";
        changelog = "https://github.com/kubernetes/kops/tree/master/docs/releases";
        license = lib.licenses.asl20;

        maintainers = with lib.maintainers; [
          zimbatm
          yurrriq
        ];

        mainProgram = "kops";
      };
    };
}

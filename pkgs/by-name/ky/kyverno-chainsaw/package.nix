{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kyverno-chainsaw";
  version = "0.2.15";

  src = fetchFromGitHub {
    owner = "kyverno";
    repo = "chainsaw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BULaac8UBF6pX7EWDKY3MFJjEEk1e5fJzTAahp/IRjs=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-DTFtbinBKWmtkbCr9+j3md00tCR9Dh2i+15NvxHjuEw=";
  doCheck = false; # requires running kubernetes

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd kyverno-chainsaw \
        --$shell <($out/bin/chainsaw completion $shell)
    done
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/kyverno/chainsaw/pkg/version.BuildVersion=v${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "chainsaw version";
    package = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Declarative approach to test Kubernetes operators and controllers";

    longDescription = ''
      Chainsaw is meant to test Kubernetes operators work as expected by running a sequence of test steps for:
      * Creating resources
      * Asserting operators react (or not) the way they should
    '';

    homepage = "https://kyverno.github.io/chainsaw/";
    changelog = "https://github.com/kyverno/chainsaw/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      LorenzBischof
    ];

    mainProgram = "chainsaw";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  rosa,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "rosa";
  version = "1.2.64";

  src = fetchFromGitHub {
    owner = "openshift";
    repo = "rosa";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lvulPx9Vyo84Lt1yo/7LKsWEh0ABkRxhusXyO/aUVrU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  # skip tests that require network access
  checkFlags =
    let
      skippedTests = [
        "TestCluster"
        "TestRhRegionCommand"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ "TestCache" ];
    in
    [ "-skip=^${lib.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd rosa \
      --bash <($out/bin/rosa completion bash) \
      --fish <($out/bin/rosa completion fish) \
      --zsh <($out/bin/rosa completion zsh)
  '';

  __darwinAllowLocalNetworking = true;
  # skip e2e tests package
  excludedPackages = [ "tests/e2e" ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "rosa version --client";
      package = rosa;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI for the Red Hat OpenShift Service on AWS";
    homepage = "https://github.com/openshift/rosa";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jfchevrette ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  go,
  installShellFiles,
  nix-update-script,
  pulsarctl,
  testers,
}:

buildGoModule rec {
  pname = "pulsarctl";
  version = "4.0.4.3";

  src = fetchFromGitHub {
    owner = "streamnative";
    repo = "pulsarctl";
    rev = "v${version}";
    hash = "sha256-acNd3nF1nHkYlw7tPoD01IjEc97dLvyAZ7yC1UDWN7s=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-AruXsUIKeUMcojf0XF1ZEaZ2LlXDwCp2n82RN5e0Rj8=";
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pulsarctl \
      --bash <($out/bin/pulsarctl completion bash) \
      --fish <($out/bin/pulsarctl completion fish) \
      --zsh <($out/bin/pulsarctl completion zsh)
  '';

  excludedPackages = [
    "./pkg/test"
    "./pkg/test/bookkeeper"
    "./pkg/test/bookkeeper/containers"
    "./pkg/test/pulsar"
    "./pkg/test/pulsar/containers"
    "./site/gen-pulsarctldocs"
    "./site/gen-pulsarctldocs/generators"
  ];

  ldflags =
    let
      buildVars = {
        BuildTS = "None";
        GitBranch = "None";
        GitHash = src.rev;
        GoVersion = "go${go.version}";
        ReleaseVersion = version;
      };
    in
    (lib.mapAttrsToList (
      k: v: "-X github.com/streamnative/pulsarctl/pkg/cmdutils.${k}=${v}"
    ) buildVars);

  passthru = {
    tests.version = testers.testVersion {
      version = "v${version}";
      command = "pulsarctl --version";
      package = pulsarctl;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI for Apache Pulsar written in Go";
    homepage = "https://github.com/streamnative/pulsarctl";
    license = with lib.licenses; [ asl20 ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pulsarctl";
  };
}

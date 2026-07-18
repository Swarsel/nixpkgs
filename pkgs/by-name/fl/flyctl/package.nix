{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  flyctl,
  git,
  installShellFiles,
  rake,
  testers,
}:

buildGoModule rec {
  pname = "flyctl";
  version = "0.4.69";

  src = fetchFromGitHub {
    owner = "superfly";
    repo = "flyctl";
    rev = "v${version}";
    hash = "sha256-e06fahSSeKTsWGR4o7XZFzcv2MfUCKLo6PrZg2tgIGU=";

    postCheckout = ''
      cd "$out"
      git rev-parse HEAD > COMMIT
    '';
  };

  patches = [
    ./disable-auto-update.patch
    ./set-commit.patch
  ];

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  vendorHash = "sha256-BLlKOu1q73T2i+B64+sLkCYXaTlHbVJ5moEwqG2JoHo=";

  preBuild = ''
    export GOFLAGS="$GOFLAGS -buildvcs=false"
    substituteInPlace internal/buildinfo/buildinfo.go \
      --replace '@commit@' "$(cat COMMIT)"
    GOOS= GOARCH= CGO_ENABLED=0 go generate ./...
  '';

  nativeCheckInputs = [ rake ];

  preCheck = ''
    HOME=$(mktemp -d)
  '';

  # We override checkPhase to be able to test ./... while using subPackages
  checkPhase = ''
    runHook preCheck
    # We do not set trimpath for tests, in case they reference test assets
    export GOFLAGS=''${GOFLAGS//-trimpath/}

    buildGoDir test ./...

    runHook postCheck
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd flyctl \
      --bash <($out/bin/flyctl completion bash) \
      --fish <($out/bin/flyctl completion fish) \
      --zsh <($out/bin/flyctl completion zsh)
    ln -s $out/bin/flyctl $out/bin/fly
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/superfly/flyctl/internal/buildinfo.buildDate=1970-01-01T00:00:00Z"
    "-X github.com/superfly/flyctl/internal/buildinfo.buildVersion=${version}"
  ];

  proxyVendor = true;
  subPackages = [ "." ];
  tags = [ "production" ];

  passthru.tests.version = testers.testVersion {
    version = "v${flyctl.version}";
    command = "HOME=$(mktemp -d) flyctl version";
    package = flyctl;
  };

  meta = {
    description = "Command line tools for fly.io services";
    homepage = "https://fly.io/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      techknowlogick
      RaghavSood
      SchahinRohani
    ];

    mainProgram = "flyctl";
    downloadPage = "https://github.com/superfly/flyctl";
  };
}

{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kapp,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kapp";
  version = "0.66.0";

  src = fetchFromGitHub {
    owner = "carvel-dev";
    repo = "kapp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Fs15mvxg3MxQpis1f9eOGOE516THazTIKs0ZiqV15Xk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  env.CGO_ENABLED = 0;

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/kapp completion $shell > kapp.$shell
      installShellCompletion kapp.$shell
    done
  '';

  ldflags = [
    "-X carvel.dev/kapp/pkg/kapp/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/kapp" ];

  passthru.tests.version = testers.testVersion {
    package = kapp;
  };

  meta = {
    description = "CLI tool that encourages Kubernetes users to manage bulk resources with an application abstraction for grouping";
    homepage = "https://carvel.dev/kapp/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ brodes ];
    mainProgram = "kapp";
  };
})

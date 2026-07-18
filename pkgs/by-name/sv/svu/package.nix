{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  svu,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "svu";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = "svu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uU5/BZA5EcIlzwoG42ZjQAkSec1hZ76pTUhK4n7bxBA=";
  };

  # test assumes source directory to be a git repository
  postPatch = ''
    rm internal/git/git_test.go
  '';

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-qRnPj4Hnf+MH96J4oYRCDBqVthHmnAoNt0CUVZZv0CI=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd svu \
      --bash <($out/bin/svu completion bash) \
      --fish <($out/bin/svu completion fish) \
      --zsh <($out/bin/svu completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.builtBy=nixpkgs"
  ];

  passthru.tests.version = testers.testVersion { package = svu; };

  meta = {
    description = "Semantic Version Util";
    homepage = "https://github.com/caarlos0/svu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ caarlos0 ];
    mainProgram = "svu";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  madonctl,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "madonctl";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "McKael";
    repo = "madonctl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-R/es9QVTBpLiCojB/THWDkgQcxexyX/iH9fF3Q2tq54=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd madonctl \
      --bash <($out/bin/madonctl completion bash) \
      --zsh <($out/bin/madonctl completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests.version = testers.testVersion {
    command = "madonctl version";
    package = madonctl;
  };

  meta = {
    description = "CLI for the Mastodon social network API";
    homepage = "https://github.com/McKael/madonctl";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "madonctl";
  };
})

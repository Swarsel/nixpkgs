{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gambit-chess,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "gambit";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "maaslalani";
    repo = "gambit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RLbD9JK1yJn30WWg7KWDjJoj4WXIoy3Kb8t2F8rFPuk=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-d9fPlv+ZAzQA42I61B5JEzfYpfJc9vWBcLYTX/s5dhs=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gambit \
      --bash <($out/bin/gambit completion bash) \
      --fish <($out/bin/gambit completion fish) \
      --zsh <($out/bin/gambit completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=v${finalAttrs.version}"
    "-X=main.CommitSHA=${finalAttrs.src.rev}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = gambit-chess;
    };
  };

  meta = {
    description = "Play chess in your terminal";
    homepage = "https://github.com/maaslalani/gambit";
    changelog = "https://github.com/maaslalani/gambit/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "gambit";
  };
})

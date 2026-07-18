{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "ory";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "ory";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MhqUg0rQigCfvbFEGrm+mBsO8ARDCxQztzK+05/4cvc=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-CbiFE/kq0w8lFJKlJt3e/ONv3ucLYHec6dWoqAJ3yuk=";
  env.CGO_ENABLED = 1;

  postInstall = ''
    mv $out/bin/cli $out/bin/ory
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    export version=v${finalAttrs.version}
    installShellCompletion --cmd ory \
      --bash <($out/bin/ory completion bash) \
      --fish <($out/bin/ory completion fish) \
      --zsh <($out/bin/ory completion zsh)
  '';

  ldflags = [
    "-X=github.com/ory/cli/buildinfo.Version=v${finalAttrs.version}"
    "-X=github.com/ory/cli/buildinfo.GitHash=${finalAttrs.src.rev}"
  ];

  subPackages = [ "." ];

  tags = [
    "sqlite"
  ];

  meta = {
    description = "CLI for Ory";
    homepage = "https://www.ory.sh/cli";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      luleyleo
      nicolas-goudry
      debtquity
    ];

    mainProgram = "ory";
  };
})

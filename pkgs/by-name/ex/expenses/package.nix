{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  sqlite,
}:

buildGoModule (finalAttrs: {
  pname = "expenses";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "manojkarthick";
    repo = "expenses";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-sqsogF2swMvYZL7Kj+ealrB1AAgIe7ZXXDLRdHL6Q+0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ sqlite ];
  vendorHash = "sha256-rIcwZUOi6bdfiWZEsRF4kl1reNPPQNuBPHDOo7RQgYo=";
  # package does not contain any tests as of v0.2.3
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd expenses \
      --bash <($out/bin/expenses completion bash) \
      --zsh <($out/bin/expenses completion zsh) \
      --fish <($out/bin/expenses completion fish)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/manojkarthick/expenses/cmd.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Interactive command line expense logger";
    homepage = "https://github.com/manojkarthick/expenses";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.manojkarthick ];
    mainProgram = "expenses";
  };
})

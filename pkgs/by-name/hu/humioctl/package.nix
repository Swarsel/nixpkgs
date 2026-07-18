{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "humioctl";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = "humio";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2vkzde4l6GIIBzzNSewCtaVlBqkqpZQGXjw7VdJFPaE=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-vGX77+I/zdTBhVSywd7msjrJ0KtcdZRgvWZWQC9M9og=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd humioctl \
      --bash <($out/bin/humioctl completion bash) \
      --zsh <($out/bin/humioctl completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "CLI for managing and sending data to Humio";
    homepage = "https://github.com/humio/cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lucperkins ];
    mainProgram = "humioctl";
  };
})

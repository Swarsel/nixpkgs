{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "gtrash";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "umlx5h";
    repo = "gtrash";
    rev = "v${finalAttrs.version}";
    hash = "sha256-odvj0YY18aishVWz5jWcLDvkYJLQ97ZSGpumxvxui4Y=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-JJA9kxNCtvfs51TzO7hEaS4UngBOEJuIIRIfHKSUMls=";
  env.CGO_ENABLED = 0;
  # disabled because it is required to run on docker.
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gtrash \
      --bash <($out/bin/gtrash completion bash) \
      --fish <($out/bin/gtrash completion fish) \
      --zsh <($out/bin/gtrash completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.builtBy=nixpkgs"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Trash CLI manager written in Go";
    homepage = "https://github.com/umlx5h/gtrash";
    changelog = "https://github.com/umlx5h/gtrash/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ umlx5h ];
    mainProgram = "gtrash";
  };
})

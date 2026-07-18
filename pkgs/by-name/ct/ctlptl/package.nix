{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "ctlptl";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "tilt-dev";
    repo = "ctlptl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/E1E3agKPYIgBjhUDGr2eKmoWH3tAbx+eSQRnDja2k0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-uARktb9Umo/SkJ8UvbOZhNSYb2ooXFybHhtY4xIVSFs=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ctlptl \
      --bash <($out/bin/ctlptl completion bash) \
      --fish <($out/bin/ctlptl completion fish) \
      --zsh <($out/bin/ctlptl completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/ctlptl" ];

  meta = {
    description = "CLI for declaratively setting up local Kubernetes clusters";
    homepage = "https://github.com/tilt-dev/ctlptl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ svrana ];
  };
})

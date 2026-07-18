{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "wander";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "robinovitch61";
    repo = "wander";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-1+bKdIAWdg/+5FBDbtvjDV0xpZ5jot3y6F+KuLO9WVk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-0S8tzP5yNUrH6fp+v7nbUPTMWzYXyGw+ZNcXkSN+tWY=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd wander \
      --fish <($out/bin/wander completion fish) \
      --bash <($out/bin/wander completion bash) \
      --zsh <($out/bin/wander completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Terminal app/TUI for HashiCorp Nomad";
    homepage = "https://github.com/robinovitch61/wander";
    license = lib.licenses.mit;
    mainProgram = "wander";
  };
})

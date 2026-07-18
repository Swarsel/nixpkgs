{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:
buildGoModule (finalAttrs: {
  pname = "netfetch";
  version = "5.2.10";

  src = fetchFromGitHub {
    owner = "deggja";
    repo = "netfetch";
    tag = finalAttrs.version;
    hash = "sha256-N3wKpWdG92cXH0TwAkcsld9TRrfPRkbw0uZY/X4d+xk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-/Em3hx5tiQjThLBPJDHGsqxUV3eXeymJ5pY9c601OW0=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    mv $out/bin/backend $out/bin/$pname
    installShellCompletion --cmd $pname \
      --bash <($out/bin/$pname completion bash) \
      --fish <($out/bin/$pname completion fish) \
      --zsh <($out/bin/$pname completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/deggja/netfetch/backend/cmd.Version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "backend" ];

  meta = {
    description = "Kubernetes tool for scanning clusters for network policies and identifying unprotected workloads";
    homepage = "https://github.com/deggja/netfetch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ banh-canh ];
    mainProgram = "netfetch";
  };
})

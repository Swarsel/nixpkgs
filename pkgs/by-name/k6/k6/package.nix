{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "k6";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "k6";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dtP2G0rk8f3TEPTf5fu/1BEH4nLzboTyE/vveVhlcqo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd k6 \
      --bash <($out/bin/k6 completion bash) \
      --fish <($out/bin/k6 completion fish) \
      --zsh <($out/bin/k6 completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/k6 version | grep ${finalAttrs.version} > /dev/null
  '';

  subPackages = [ "./" ];

  meta = {
    description = "Modern load testing tool, using Go and JavaScript";
    homepage = "https://k6.io/";
    changelog = "https://github.com/grafana/k6/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      kashw2
    ];

    mainProgram = "k6";
  };
})

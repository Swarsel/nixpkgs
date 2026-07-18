{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  go,
  installShellFiles,
  nix-update-script,
  testers,
  updatecli,
}:

buildGoModule (finalAttrs: {
  pname = "updatecli";
  version = "0.117.1";

  src = fetchFromGitHub {
    owner = "updatecli";
    repo = "updatecli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-24ZL2o5TauhPFDG6evOSHJUX3ZMDlekpUu5zvh2ZEQE=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-q53DDtSBYaXJElJZU4KV4Y3o0OIuOTPF0pskqpmQWXk=";
  env.CGO_ENABLED = 0;
  # tests require network access
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd updatecli \
      --bash <($out/bin/updatecli completion bash) \
      --fish <($out/bin/updatecli completion fish) \
      --zsh <($out/bin/updatecli completion zsh)

    $out/bin/updatecli man > updatecli.1
    installManPage updatecli.1
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/updatecli/updatecli/pkg/core/version.BuildTime=unknown"
    ''-X "github.com/updatecli/updatecli/pkg/core/version.GoVersion=go version go${lib.getVersion go}"''
    "-X github.com/updatecli/updatecli/pkg/core/version.Version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  passthru = {
    tests.version = testers.testVersion {
      command = "updatecli version";
      package = updatecli;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Declarative Dependency Management tool";

    longDescription = ''
      Updatecli is a command-line tool used to define and apply update strategies.
    '';

    homepage = "https://www.updatecli.io";
    changelog = "https://github.com/updatecli/updatecli/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      croissong
      lpostula
    ];

    mainProgram = "updatecli";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  doppler,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "doppler";
  version = "3.76.0";

  src = fetchFromGitHub {
    owner = "dopplerhq";
    repo = "cli";
    rev = finalAttrs.version;
    hash = "sha256-CmNSn4WRWMP07qC5APw8PTouCUOHJrz1ZYqpKhdiIDM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-u6SB3SXCqu7Y2aUoTAJ01mtDCxMofVQLAde1jDxVvks=";

  postInstall = ''
    mv $out/bin/cli $out/bin/doppler
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    export HOME=$TMPDIR
    mkdir $HOME/.doppler # to avoid race conditions below
    installShellCompletion --cmd doppler \
      --bash <($out/bin/doppler completion bash) \
      --fish <($out/bin/doppler completion fish) \
      --zsh <($out/bin/doppler completion zsh)
  '';

  ldflags = [
    "-s -w"
    "-X github.com/DopplerHQ/cli/pkg/version.ProgramVersion=v${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = doppler;
  };

  meta = {
    description = "Official CLI for interacting with your Doppler Enclave secrets and configuration";
    homepage = "https://doppler.com";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lucperkins ];
    mainProgram = "doppler";
  };
})

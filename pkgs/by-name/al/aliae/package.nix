{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "aliae";
  version = "0.26.6";

  src = fetchFromGitHub {
    owner = "jandedobbeleer";
    repo = "aliae";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W/jj2YQc6M0ro4groCynly2stjv2FLAMvIopnQYCngY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-8YTyhjF0p2l76sowq92ts5TjjcARToOfJN9nlFu19L4=";

  postInstall = ''
    mv $out/bin/{src,aliae}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd aliae \
      --bash <($out/bin/aliae completion bash) \
      --fish <($out/bin/aliae completion fish) \
      --zsh <($out/bin/aliae completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  tags = [
    "netgo"
    "osusergo"
  ];

  meta = {
    description = "Cross shell and platform alias management";
    homepage = "https://aliae.dev";
    changelog = "https://github.com/JanDeDobbeleer/aliae/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vedantmgoyal9 ];
    mainProgram = "aliae";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  testers,
  twitch-cli,
}:

buildGoModule (finalAttrs: {
  pname = "twitch-cli";
  version = "1.1.25";

  src = fetchFromGitHub {
    owner = "twitchdev";
    repo = "twitch-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+6/o2vhj1iaT0hkyQRedn7ga1dhNZOupX4lOadnTDU0=";
  };

  patches = [
    ./application-name.patch
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-LPpUnielSeGE0k68z+M565IqXQUIkAh5xloOqcbfh20=";

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/twitch-cli completion bash > twitch-cli.bash
    $out/bin/twitch-cli completion fish > twitch-cli.fish
    $out/bin/twitch-cli completion zsh > _twitch-cli
    installShellCompletion --cmd twitch-cli \
      --bash twitch-cli.bash \
      --fish twitch-cli.fish \
      --zsh _twitch-cli
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X=main.buildVersion=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "twitch-cli/${finalAttrs.version}";
    command = "HOME=$(mktemp -d) twitch-cli version";
    package = twitch-cli;
  };

  meta = {
    description = "Official Twitch CLI to make developing on Twitch easier";
    homepage = "https://github.com/twitchdev/twitch-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ benediktbroich ];
    mainProgram = "twitch-cli";
  };
})

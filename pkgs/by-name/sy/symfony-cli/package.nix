{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeBinaryWrapper,
  nix-update-script,
  nssTools,
  symfony-cli,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "symfony-cli";
  version = "5.18.1";

  src = fetchFromGitHub {
    owner = "symfony-cli";
    repo = "symfony-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sd1C33n0Eo/lV9Uas+EcEojIYLRosuzcZn9se5dwukU=";
    leaveDotGit = true;

    postFetch = ''
      git --git-dir $out/.git log -1 --pretty=%cd --date=format:'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE
      rm -rf $out/.git
    '';
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ makeBinaryWrapper ];
  vendorHash = "sha256-xAOp03sbtJv31nikkWHhBEHNQkDJ0RtPTPVPpw/6Eho=";

  preBuild = ''
    ldflags+=" -X main.buildDate=$(cat SOURCE_DATE)"
  '';

  # Tests require network access
  doCheck = false;

  postInstall = ''
    mkdir $out/libexec
    mv $out/bin/symfony-cli $out/libexec/symfony

    makeBinaryWrapper $out/libexec/symfony $out/bin/symfony \
      --prefix PATH : ${lib.makeBinPath [ nssTools ]}

    installShellCompletion --cmd symfony \
      --bash <($out/bin/symfony completion bash) \
      --fish <($out/bin/symfony completion fish) \
      --zsh <($out/bin/symfony completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.channel=stable"
  ];

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "symfony version --no-ansi";
      package = symfony-cli;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Symfony CLI";
    homepage = "https://github.com/symfony-cli/symfony-cli";
    changelog = "https://github.com/symfony-cli/symfony-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ patka ];
    mainProgram = "symfony";
  };
})

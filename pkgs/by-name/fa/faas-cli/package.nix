{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  faas-cli,
  git,
  installShellFiles,
  makeWrapper,
  testers,
}:
let
  faasPlatform =
    platform:
    let
      cpuName = platform.parsed.cpu.name;
    in
    {
      "aarch64" = "arm64";
      "armv6l" = "armhf";
      "armv7l" = "armhf";
    }
    .${cpuName} or cpuName;
in
buildGoModule (finalAttrs: {
  pname = "faas-cli";
  version = "0.18.10";

  src = fetchFromGitHub {
    owner = "openfaas";
    repo = "faas-cli";
    rev = finalAttrs.version;
    sha256 = "sha256-MctMhuaXJpm25VKqlhaAPG2QzSDQ//Ei8B1lRCKdz68=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  vendorHash = null;
  env.CGO_ENABLED = 0;

  postInstall = ''
    wrapProgram "$out/bin/faas-cli" \
      --prefix PATH : ${lib.makeBinPath [ git ]}

    installShellCompletion --cmd metal \
      --bash <($out/bin/faas-cli completion --shell bash) \
      --zsh <($out/bin/faas-cli completion --shell zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/openfaas/faas-cli/version.GitCommit=ref/tags/${finalAttrs.version}"
    "-X github.com/openfaas/faas-cli/version.Version=${finalAttrs.version}"
    "-X github.com/openfaas/faas-cli/commands.Platform=${faasPlatform stdenv.hostPlatform}"
  ];

  subPackages = [ "." ];

  passthru.tests.version = testers.testVersion {
    command = "${faas-cli}/bin/faas-cli version --short-version --warn-update=false";
    package = faas-cli;
  };

  meta = {
    description = "Official CLI for OpenFaaS";
    homepage = "https://github.com/openfaas/faas-cli";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      welteki
      techknowlogick
    ];

    mainProgram = "faas-cli";
  };
})

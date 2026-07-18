{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  dependabot-cli,
  dockerTools,
  installShellFiles,
  makeWrapper,
  symlinkJoin,
  testers,
}:
let
  pname = "dependabot-cli";
  version = "1.91.0";

  # `tag` is what `dependabot` uses to find the relevant docker images.
  tag = "nixpkgs-dependabot-cli-${version}";

  # Get these hashes from
  # nix run nixpkgs#nix-prefetch-docker -- --image-name ghcr.io/github/dependabot-update-job-proxy/dependabot-update-job-proxy --image-tag latest --final-image-name dependabot-update-job-proxy --final-image-tag ${tag}
  updateJobProxy.imageDigest = "sha256:70cf9a8f006db9cde732faf9e33a4f60af895532bbe803268fc8fd2f70aa3202";
  updateJobProxy.hash = "sha256-IBUBBSXHwepTqvcWJyo5St+ceCc80ml0Arf6R9v54Eg=";

  # Get these hashes from
  # nix run nixpkgs#nix-prefetch-docker -- --image-name ghcr.io/dependabot/dependabot-updater-github-actions --image-tag latest --final-image-name dependabot-updater-github-actions --final-image-tag ${tag}
  updaterGitHubActions.imageDigest = "sha256:57b7da54e9ce0f360523f27b3536f38af1606bf6a0a74a906d39fb9fa5caf80a";
  updaterGitHubActions.hash = "sha256-cuAlu1PovPztc3P79bz8ySRCCDKh3dbt2WA4/ws6In8=";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "dependabot";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-8wDP9NRsO/xbtbRTXY1BviEbZUEsiZBosJAni62uyFE=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  vendorHash = "sha256-mo/OOo+vw2jX0ggeEzNE8Qr5xXg0GEaTH6krdGQyeEE=";
  # Some tests fail on *-darwin because they require host port binding or a Docker environment.
  # So, we skip the test entirely on *-darwin.
  doCheck = !stdenv.hostPlatform.isDarwin;

  checkFlags = [
    "-skip=TestDependabot"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd dependabot \
      --bash <($out/bin/dependabot completion bash) \
      --fish <($out/bin/dependabot completion fish) \
      --zsh <($out/bin/dependabot completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/dependabot --help
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dependabot/cli/cmd/dependabot/internal/cmd.version=v${version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${version}";
    command = "dependabot --version";
    package = dependabot-cli;
  };

  passthru.updateScript = ./update.sh;

  passthru.withDockerImages = symlinkJoin {
    buildInputs = [ makeWrapper ];

    postBuild =
      let
        updateJobProxyImage = dockerTools.pullImage {
          inherit (updateJobProxy) imageDigest hash;
          finalImageName = "dependabot-update-job-proxy";
          finalImageTag = tag;
          imageName = "ghcr.io/github/dependabot-update-job-proxy/dependabot-update-job-proxy";
        };

        updaterGitHubActionsImage = dockerTools.pullImage {
          inherit (updaterGitHubActions) imageDigest hash;
          finalImageName = "dependabot-updater-github-actions";
          finalImageTag = tag;
          imageName = "ghcr.io/dependabot/dependabot-updater-github-actions";
        };
      in
      ''
        # Create a wrapper that pins the docker images that `dependabot` uses.
        wrapProgram $out/bin/dependabot \
          --run "docker load --input ${updateJobProxyImage} >&2" \
          --add-flags "--proxy-image=dependabot-update-job-proxy:${tag}" \
          --run "docker load --input ${updaterGitHubActionsImage} >&2" \
          --add-flags "--updater-image=dependabot-updater-github-actions:${tag}"
      '';

    name = "dependabot-cli-with-docker-images";
    paths = [ dependabot-cli ];
  };

  meta = {
    description = "Tool for testing and debugging Dependabot update jobs";
    homepage = "https://github.com/dependabot/cli";
    changelog = "https://github.com/dependabot/cli/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      infinisil
      philiptaron
    ];

    mainProgram = "dependabot";
  };
}

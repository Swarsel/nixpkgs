{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "scmpuff";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "mroth";
    repo = "scmpuff";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-c8F7BgjbR/w2JH8lE2t93s8gj6cWbTQGIkgYTQp9R3U=";
  };

  strictDeps = true;
  vendorHash = "sha256-7xSMToc5rlxogS0N9H6siauu8i33zUA5/omqXAszDOg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    # see .goreleaser.yml in the repository
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
    "-X main.date=1970-01-01T00:00:00Z"
    "-X main.builtBy=nixpkgs"
    "-X main.treeState=clean"
  ];

  meta = {
    description = "Numeric file shortcuts for common git commands";
    homepage = "https://github.com/mroth/scmpuff";
    changelog = "https://github.com/mroth/scmpuff/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cpcloud
      christoph-heiss
    ];

    mainProgram = "scmpuff";
  };
})

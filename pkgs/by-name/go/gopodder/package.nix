{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gopodder";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "cbrgm";
    repo = "gopodder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o/iQnr8WLArecRyMttCluuEYwKirKsOJyj5a7tdulVo=";
  };

  vendorHash = "sha256-iG2IUfBVLQ7P0W4HOiGShVyD4mGUQ0dfGjG4XIYVtWU=";
  env.CGO_ENABLED = 0;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
    "-X main.Revision=${finalAttrs.src.tag}"
    "-X main.BuildDate=1970-01-01"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Self-hostable podcast synchronization server compatible with the gPodder API";
    homepage = "https://github.com/cbrgm/gopodder";
    changelog = "https://github.com/cbrgm/gopodder/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nielmin ];
    mainProgram = "gopodder";
  };
})

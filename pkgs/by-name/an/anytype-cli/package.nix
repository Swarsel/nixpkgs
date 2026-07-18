{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  tantivy-go,
}:
buildGoModule (finalAttrs: {
  pname = "anytype-cli";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T/mdF+pzApm15Cg2g1ybgU7pEHLsTC4jD7WuXzNqM2M=";
  };

  vendorHash = "sha256-S6Xb2XYAn/cTC++1WK5cmXcC6QCZpPoYMRrjk/IPKas=";
  env.CGO_ENABLED = 1;
  env.CGO_LDFLAGS = "-L${tantivy-go}/lib";
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/anyproto/anytype-cli/core.Version=v${finalAttrs.version}"
  ];

  proxyVendor = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line interface for interacting with Anytype";
    homepage = "https://github.com/anyproto/anytype-cli";
    changelog = "https://github.com/anyproto/anytype-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      adda
      wanderer
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "anytype-cli";
  };
})

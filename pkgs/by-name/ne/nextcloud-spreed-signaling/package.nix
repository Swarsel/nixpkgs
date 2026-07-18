{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "nextcloud-spreed-signaling";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "strukturag";
    repo = "nextcloud-spreed-signaling";
    tag = "v${finalAttrs.version}";
    hash = "sha256-thXTIvaEufGOYWFMiqZxUcqhZbXRQgTj2FeZ2s/gqaI=";
  };

  strictDeps = true;
  vendorHash = "sha256-qLyehDoZZBCzlc8X/il1+8gtX6M/nhjqUKccebuxLVE=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dedicated signaling backend for nextcloud talk";
    homepage = "https://github.com/strukturag/nextcloud-spreed-signaling";
    changelog = "https://github.com/strukturag/nextcloud-spreed-signaling/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      hensoko
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "server";
    downloadPage = "https://github.com/strukturag/nextcloud-spreed-signaling/releases/tag/v${finalAttrs.version}";
  };
})

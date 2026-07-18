{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "komari-agent";
  version = "1.2.13";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    tag = finalAttrs.version;
    hash = "sha256-k1dzWVau2wD641TARNwhdiOV4havglB7099nMG+Mt/Y=";
  };

  vendorHash = "sha256-teKx9u7M2ZQdd7G3xSCqhwjcHRzBzKeBViSl62TRg+g=";
  # tests require network access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight server probe for simple, efficient monitoring";
    homepage = "https://github.com/komari-monitor/komari-agent";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mlyxshi
    ];

    mainProgram = "komari-agent";
  };
})

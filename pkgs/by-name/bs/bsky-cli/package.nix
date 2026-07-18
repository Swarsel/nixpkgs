{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libpcap,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "bsky-cli";
  version = "0.0.81";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = "bsky";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Su2AhHaIozuqTzK1vyAjZR/a01j0dnlayV14Q7hTcCU=";
  };

  nativeBuildInputs = [ versionCheckHook ];

  buildInputs = [
    libpcap
  ];

  vendorHash = "sha256-jGeKaAR0rAqrhoUx/FqdDwdOxA/WioppFjGyi/PsIQs=";
  doInstallCheck = true;

  ldflags = [
    "-s"
    "-w"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/bsky";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cli application for bluesky social";
    homepage = "https://github.com/mattn/bsky";
    changelog = "https://github.com/mattn/bsky/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainProgram = "bsky";
  };
})

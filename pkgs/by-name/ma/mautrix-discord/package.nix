{
  lib,
  fetchFromGitHub,
  buildGoModule,
  mautrix-discord,
  nix-update-script,
  olm,
  testers,
}:

buildGoModule rec {
  pname = "mautrix-discord";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "discord";
    rev = "v${version}";
    hash = "sha256-qpyySoYX+JMEKDf7Iv5WSZFOxkrmd3ihAaAXAKcZs9Q=";
  };

  buildInputs = [ olm ];
  vendorHash = "sha256-ZjY2+1M1LP/zBVG5+zfX4T8Lyjx/tpDwSxLlpsBG3iA=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    tests.version = testers.testVersion {
      package = mautrix-discord;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Matrix-Discord puppeting bridge";
    homepage = "https://github.com/mautrix/discord";
    changelog = "https://github.com/mautrix/discord/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      sumnerevans
    ];

    mainProgram = "mautrix-discord";
  };
}

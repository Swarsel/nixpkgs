{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go-critic,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "go-critic";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "go-critic";
    repo = "go-critic";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RrofJ2/IsndBYvGZLlMbz7kZUGtMOwM4kGrzAiAk0Qs=";
  };

  vendorHash = "sha256-2tzBJI2d9/EY1lPgJDrOGfgh8dz2bYwP5kWifJ46a8I=";
  allowGoReference = true;

  ldflags = [
    "-X main.Version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/gocritic"
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "gocritic version";
      package = go-critic;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Most opinionated Go source code linter for code audit";
    homepage = "https://go-critic.com/";
    changelog = "https://github.com/go-critic/go-critic/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ katexochen ];
    mainProgram = "gocritic";
  };
})

{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "nakama";
  version = "3.39.0";

  src = fetchFromGitHub {
    owner = "heroiclabs";
    repo = "nakama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+yHQ2KxH/Kzv8s3hPsOh3IQZvSPeAwWHYHHHh3NR8VA=";
  };

  postPatch = ''
    substituteInPlace main.go \
      --replace-fail  'os.Getenv("NAKAMA_TELEMETRY") != "0"' \
                      'os.Getenv("NAKAMA_TELEMETRY") == "1"'
  '';

  vendorHash = null;
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Distributed server for social and realtime games and apps";
    homepage = "https://heroiclabs.com/nakama/";
    changelog = "https://github.com/heroiclabs/nakama/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.qxrein ];
    platforms = lib.platforms.linux;
    mainProgram = "nakama";
  };
})

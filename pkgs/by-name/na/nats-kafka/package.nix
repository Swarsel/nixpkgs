{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "nats-kafka";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "nats-kafka";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RboNlKpD+4mOx6iL6JpguR90y6Ux1x0twFcazIPj0w0=";
  };

  vendorHash = "sha256-Zo4lAV/1TIblTbFrZcwvVecvAAgX+8N6OmdeNyI6Ja0=";
  # needs running nats-server and kafka
  doCheck = false;

  ldflags = [
    "-X github.com/nats-io/nats-kafka/server/core.Version=v${finalAttrs.version}"
  ];

  # do not build & install test binaries
  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "NATS to Kafka Bridging";
    homepage = "https://github.com/nats-io/nats-kafka";
    changelog = "https://github.com/nats-io/nats-kafka/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ misuzu ];
    mainProgram = "nats-kafka";
  };
})

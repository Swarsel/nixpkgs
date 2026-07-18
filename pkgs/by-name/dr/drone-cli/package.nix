{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "drone-cli";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "harness";
    repo = "drone-cli";
    rev = revision;
    hash = "sha256-XE0myh+PAl8JhoUhEdjdCe52vQo3NuA8/v/x+v5zHK4=";
  };

  # patch taken from https://patch-diff.githubusercontent.com/raw/harness/drone-cli/pull/179.patch
  # but with go.mod changes removed due to conflict
  patches = [ ./0001-use-builtin-go-syscerts.patch ];
  vendorHash = "sha256-22sefx/2iLvVzN+6wJ7kbDFAv10PQNmWbia+HFzmaW8=";

  ldflags = [
    "-X main.version=${version}"
  ];

  revision = "v${version}";

  meta = {
    description = "Command line client for the Drone continuous integration server";
    homepage = "https://github.com/harness/drone-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ techknowlogick ];
    mainProgram = "drone";
  };
}

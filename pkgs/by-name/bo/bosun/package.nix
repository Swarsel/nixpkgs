{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "bosun";
  version = "unstable-2021-05-13";

  src = fetchFromGitHub {
    owner = "bosun-monitor";
    repo = "bosun";
    rev = "e25bc3e69a1fb2e29d28f13a78ffa71cc0b8cc87";
    hash = "sha256-YL1RqoryHRWKyUwO9NE8z/gsE195D+vFWR8YpZH+gbw=";
  };

  vendorHash = "sha256-5mVI5cyuIB+6KHlTpDxSNGU7yBsGQC4IA+iDgvVFVZM=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/bosun"
    "cmd/scollector"
  ];

  meta = {
    description = "Time Series Alerting Framework";
    homepage = "https://bosun.org";
    license = lib.licenses.mit;
    maintainers = [ ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}

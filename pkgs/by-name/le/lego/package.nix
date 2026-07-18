{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "lego";
  version = "4.35.2";

  src = fetchFromGitHub {
    owner = "go-acme";
    repo = "lego";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NBCvVlMDEEhlfWWG7X5T1Udg+42+ibS1Ph6F+/yrXF0=";
  };

  vendorHash = "sha256-Q85McGGSILE8BPwreCtih6my1nih9ameLKHFe1dgNWQ=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/lego" ];

  passthru.tests = {
    lego-dns = nixosTests.acme.dns01;
    lego-http = nixosTests.acme.http01-builtin;
  };

  meta = {
    description = "Let's Encrypt client and ACME library written in Go";
    homepage = "https://go-acme.github.io/lego/";
    license = lib.licenses.mit;
    mainProgram = "lego";
    teams = [ lib.teams.acme ];
  };
})

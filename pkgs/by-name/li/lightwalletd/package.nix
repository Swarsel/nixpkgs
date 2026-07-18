{
  lib,
  fetchFromGitHub,
  buildGoModule,
  lightwalletd,
  testers,
}:

buildGoModule rec {
  pname = "lightwalletd";
  version = "0.4.19";

  src = fetchFromGitHub {
    owner = "zcash";
    repo = "lightwalletd";
    rev = "v${version}";
    hash = "sha256-93zR2rVRrV09rflfJbT3JMYmqyx0Lp0Acbs2ohhUL8Y=";
  };

  vendorHash = "sha256-bV1nJ1HUpYdziV42/ug3X+/jAdw3Wq7MdcnX327MD/w=";

  excludedPackages = [
    "genblocks"
    "testclient"
    "zap"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/zcash/lightwalletd/common.Version=v${version}"
    "-X github.com/zcash/lightwalletd/common.GitCommit=${src.rev}"
    "-X github.com/zcash/lightwalletd/common.BuildDate=1970-01-01"
    "-X github.com/zcash/lightwalletd/common.BuildUser=nixbld"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${lightwalletd.version}";
    command = "lightwalletd version";
    package = lightwalletd;
  };

  meta = {
    description = "Backend service that provides a bandwidth-efficient interface to the Zcash blockchain";
    homepage = "https://github.com/zcash/lightwalletd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ centromere ];
    mainProgram = "lightwalletd";
  };
}

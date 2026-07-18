{
  lib,
  fetchFromGitHub,
  buildGoModule,
  rain,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "rain";
  version = "1.24.4";

  src = fetchFromGitHub {
    owner = "aws-cloudformation";
    repo = "rain";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-akckpNDlv9TuDVkFLEhsx61GYNMrjBE2cM/mXmVtrCA=";
  };

  vendorHash = "sha256-bREmqt9QDuPqhfTIIY1FBfOcNqGS8JXjlMqM99tBI9g=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/rain" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "rain --version";
    package = rain;
  };

  meta = {
    description = "Development workflow tool for working with AWS CloudFormation";
    homepage = "https://github.com/aws-cloudformation/rain";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jiegec ];
    mainProgram = "rain";
  };
})

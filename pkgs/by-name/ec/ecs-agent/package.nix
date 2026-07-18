{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "amazon-ecs-agent";
  version = "1.101.2";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "amazon-ecs-agent";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J4gjkULtkU1LMHBNcm/QQ407uWMZ6jREP9MdSK0Js44=";
  };

  vendorHash = null;
  excludedPackages = [ "./version/gen" ];

  ldflags = [
    "-s"
    "-w"
  ];

  modRoot = "./agent";

  meta = {
    description = "Agent that runs on AWS EC2 container instances and starts containers on behalf of Amazon ECS";
    homepage = "https://github.com/aws/amazon-ecs-agent";
    changelog = "https://github.com/aws/amazon-ecs-agent/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "agent";
  };
})

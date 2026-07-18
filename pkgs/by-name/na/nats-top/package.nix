{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nats-top,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "nats-top";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "nats-top";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yewSURZ5uFfDiSRjLmv8QU7XxTVsnZK2RvsPQ/ZEkRw=";
  };

  vendorHash = "sha256-BY2WPwU6my1cqddgZvZl36KXKCpMo5RLT4bhk/b+xCM=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = nats-top;
    };
  };

  meta = {
    description = "top-like tool for monitoring NATS servers";
    homepage = "https://github.com/nats-io/nats-top";
    changelog = "https://github.com/nats-io/nats-top/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "nats-top";
  };
})

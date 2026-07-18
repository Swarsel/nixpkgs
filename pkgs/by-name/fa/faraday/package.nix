{
  lib,
  fetchFromGitHub,
  buildGoModule,
  faraday,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "faraday";
  version = "0.2.14-alpha";

  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "faraday";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7sCNHrtDDpxpcxmHTVq8reHjNMXKyxPbYM6H6Eqo+OY=";
  };

  vendorHash = "sha256-xlyZEcFphXAV+7iHmJBZiQWKKBDm1cpE2Eax2fWYd0Y=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/frcli"
    "cmd/faraday"
  ];

  passthru.tests.version = testers.testVersion {
    package = faraday;
  };

  meta = {
    description = "LND Channel Management Tools";
    homepage = "https://github.com/lightninglabs/faraday";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ proofofkeags ];
  };
})

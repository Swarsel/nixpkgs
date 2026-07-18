{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "taproot-assets";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "taproot-assets";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pgsorq+dWjGTkbdrHSIZm36S16xhcjvDCUin2bzcldc=";
  };

  vendorHash = "sha256-K8XwCRTj4UECZpVb8g7+6VAC4khTcnRrhPaKDXJvJCI=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/tapcli"
    "cmd/tapd"
  ];

  meta = {
    description = "Daemon for the Taproot Assets protocol specification";
    homepage = "https://github.com/lightninglabs/taproot-assets";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
  };
})

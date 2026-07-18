{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "chamber";
  version = "3.1.5";

  src = fetchFromGitHub {
    owner = "segmentio";
    repo = "chamber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vmWRbQzgZJA2dQMdmZ/dLFlYb5O2yAexBZt3Oc2FLMM=";
  };

  vendorHash = "sha256-Yin8hNavlcANY8ynmzceLVHUfgk/MbH9Xx9MfW12E+0=";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Tool for managing secrets by storing them in AWS SSM Parameter Store";
    homepage = "https://github.com/segmentio/chamber";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kalekseev ];
    mainProgram = "chamber";
  };
})

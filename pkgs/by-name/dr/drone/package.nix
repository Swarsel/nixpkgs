{
  lib,
  fetchFromGitHub,
  buildGoModule,
  enableUnfree ? true,
}:

buildGoModule (finalAttrs: {
  pname = "drone.io${lib.optionalString (!enableUnfree) "-oss"}";
  version = "2.28.2";

  src = fetchFromGitHub {
    owner = "harness";
    repo = "harness";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jKM+jET6dsMe5+QRDKIHA40OOHb/nZmli3owaDB7IvU=";
  };

  vendorHash = "sha256-BHfuQ4bloqvdqHK4HSlzHVd9r0yhGkWqLY0XZazwiZQ=";
  doCheck = false;

  tags = lib.optionals (!enableUnfree) [
    "oss"
    "nolimit"
  ];

  meta = {
    description = "Continuous Integration platform built on container technology";
    homepage = "https://github.com/harness/harness";
    license = with lib.licenses; if enableUnfree then unfreeRedistributable else asl20;

    maintainers = with lib.maintainers; [
      vdemeester
      techknowlogick
    ];

    mainProgram = "drone-server";
  };
})

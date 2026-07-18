{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "lk-jwt-service";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "element-hq";
    repo = "lk-jwt-service";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BwFcknSXC3uZfSlS0a420/WpUn/ji2m9x65zKi3bumE=";
  };

  vendorHash = "sha256-1D04GhXhGrOcRn8G+xY+3XEdgUBSWHis4DiKQ4gGNDw=";
  passthru.tests = nixosTests.lk-jwt-service;

  meta = {
    description = "Minimal service to issue LiveKit JWTs for MatrixRTC";
    homepage = "https://github.com/element-hq/lk-jwt-service";
    changelog = "https://github.com/element-hq/lk-jwt-service/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ kilimnik ];
    mainProgram = "lk-jwt-service";
  };
})

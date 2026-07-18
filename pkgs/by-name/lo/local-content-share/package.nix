{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "local-content-share";
  version = "37";

  src = fetchFromGitHub {
    owner = "Tanq16";
    repo = "local-content-share";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M7C95scyTBcmfH96BEWSK3wQFzv491ADw1SH9IvmwiY=";
  };

  vendorHash = null;
  # no test file in upstream
  doCheck = false;
  passthru.tests.nixos = nixosTests.local-content-share;

  meta = {
    description = "Storing/sharing text/files in your local network with no setup on client devices";
    homepage = "https://github.com/Tanq16/local-content-share";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ e-v-o-l-v-e ];
    platforms = lib.platforms.unix;
    mainProgram = "local-content-share";
  };
})

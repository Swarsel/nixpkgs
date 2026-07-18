{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "ergo";
  version = "2.17.0";

  src = fetchFromGitHub {
    owner = "ergochat";
    repo = "ergo";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ajLecAgE74Et7XRGtpGoA9DAcSzBEtRzLm47nHn1Amo=";
  };

  vendorHash = null;
  passthru.tests.ergochat = nixosTests.ergochat;

  meta = {
    description = "Modern IRC server (daemon/ircd) written in Go";
    homepage = "https://github.com/ergochat/ergo";
    changelog = "https://github.com/ergochat/ergo/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lassulus
      tv
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ergo";
  };
})

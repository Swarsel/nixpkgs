{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "pingme";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "kha7iq";
    repo = "pingme";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KqXnekhgWlebfkUzKfwqy3ouawfdTRb1M8QKN+TJNh8=";
  };

  vendorHash = "sha256-NpSgVUbft2chKdRwE6n5kwhAZMmVVa6NCWkxWL3wCac=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Send messages or alerts to multiple messaging platforms & email";
    homepage = "https://pingme.lmno.pk";
    changelog = "https://github.com/kha7iq/pingme/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emilytrau ];
    mainProgram = "pingme";
  };
})

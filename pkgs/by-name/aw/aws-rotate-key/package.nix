{
  lib,
  fetchFromGitHub,
  aws-rotate-key,
  buildGoModule,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "aws-rotate-key";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "stefansundin";
    repo = "aws-rotate-key";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fYpgHHOw0k/8WLGhq+uVOvoF4Wff6wzTXuN8r4D+TmU=";
  };

  vendorHash = "sha256-gXtTd7lU9m9rO1w7Fx8o/s45j63h6GtUZrjOzFI4Q/o=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests.version = testers.testVersion {
    command = "AWS_SHARED_CREDENTIALS_FILE=/dev/null aws-rotate-key --version";
    package = aws-rotate-key;
  };

  meta = {
    description = "Easily rotate your AWS key";
    homepage = "https://github.com/stefansundin/aws-rotate-key";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mbode ];
    mainProgram = "aws-rotate-key";
  };
})

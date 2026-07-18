{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ssmsh,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "ssmsh";
  version = "1.4.9";

  src = fetchFromGitHub {
    owner = "bwhaley";
    repo = "ssmsh";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-UmfwDukRVyfX+DmUfRi+KepqFrPtDNImKd22/dI7ytk=";
  };

  vendorHash = "sha256-+7duWRe/haBOZbe18sr2qwg419ieEZwYDb0L3IPLA4A=";
  doCheck = true;

  ldflags = [
    "-w"
    "-s"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.tests = testers.testVersion {
    version = "Version ${finalAttrs.version}";
    command = "ssmsh -version";
    package = ssmsh;
  };

  meta = {
    description = "Interactive shell for AWS Parameter Store";
    homepage = "https://github.com/bwhaley/ssmsh";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dbirks ];
    mainProgram = "ssmsh";
  };
})

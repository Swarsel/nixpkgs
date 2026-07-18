{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ejsonkms,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "ejsonkms";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "envato";
    repo = "ejsonkms";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AvOHsmcubKZH9uMwE/iwlC4ORAc9ie0H3Nyq2n+CDCs=";
  };

  vendorHash = "sha256-6C/hZwqB6yqFjfDe+KQAY+ja41v/FVaEmPEUXb0FZTA=";
  doCheck = false;

  ldflags = [
    "-X main.version=v${finalAttrs.version}"
    "-s"
    "-w"
  ];

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = ejsonkms;
    };
  };

  meta = {
    description = "Integrates EJSON with AWS KMS";
    homepage = "https://github.com/envato/ejsonkms";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viraptor ];
  };
})

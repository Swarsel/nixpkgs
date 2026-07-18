{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "cfssl";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cfssl";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Xczpv6tLJiy2dXoGJ0QUmXwOn0p6S+lm2oz61oytQec=";
  };

  vendorHash = null;
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/cloudflare/cfssl/cli/version.version=v${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/cfssl"
    "cmd/cfssljson"
    "cmd/cfssl-bundle"
    "cmd/cfssl-certinfo"
    "cmd/cfssl-newkey"
    "cmd/cfssl-scan"
    "cmd/multirootca"
    "cmd/mkbundle"
  ];

  passthru.tests = { inherit (nixosTests) cfssl; };

  meta = {
    description = "Cloudflare's PKI and TLS toolkit";
    homepage = "https://cfssl.org/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ mbrgm ];
    mainProgram = "cfssl";
  };
})

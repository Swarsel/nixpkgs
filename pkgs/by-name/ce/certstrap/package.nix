{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "certstrap";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "square";
    repo = "certstrap";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-mbZtomR8nnawXr3nGVSEuVObe79M1CqTlYN/aEpKmcU=";
  };

  vendorHash = "sha256-r7iYhTmFKTjfv11fEerC72M7JBp64rWfbkoTKzObNqM=";
  ldflags = [ "-X main.release=${finalAttrs.version}" ];
  subPackages = [ "." ];

  meta = {
    description = "Tools to bootstrap CAs, certificate requests, and signed certificates";

    longDescription = ''
      A simple certificate manager written in Go, to bootstrap your own
      certificate authority and public key infrastructure. Adapted from etcd-ca.
    '';

    homepage = "https://github.com/square/certstrap";
    changelog = "https://github.com/square/certstrap/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "certstrap";
  };
})

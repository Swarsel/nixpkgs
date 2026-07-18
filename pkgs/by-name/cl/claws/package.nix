{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "claws";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "thehowl";
    repo = "claws";
    rev = finalAttrs.version;
    hash = "sha256-3zzUBeYfu9x3vRGX1DionLnAs1e44tFj8Z1dpVwjdCg=";
  };

  vendorHash = "sha256-FP+3Rw5IdCahhx9giQrpepMMtF1pWcyjNglrlu9ju0Q=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Interactive command line client for testing websocket servers";
    homepage = "https://github.com/thehowl/claws";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "claws";
  };
})

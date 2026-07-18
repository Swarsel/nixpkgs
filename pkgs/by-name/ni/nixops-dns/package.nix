{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "nixops-dns";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "museoa";
    repo = "nixops-dns";
    rev = "v${finalAttrs.version}";
    hash = "sha256-d3vVm6YeQTOAE5HFSKI01L9ZqfbQKrdoLsMwHP5HulE=";
  };

  vendorHash = "sha256-3DVNjvW0AAdogpTi3GMnn92FqqOUWNdQvRBityyKwcI=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "DNS server for resolving NixOps machines";
    homepage = "https://github.com/museoa/nixops-dns";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kamilchm
      sorki
    ];

    mainProgram = "nixops-dns";
  };
})

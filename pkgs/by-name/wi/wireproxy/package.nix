{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  wireproxy,
}:

buildGoModule (finalAttrs: {
  pname = "wireproxy";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "windtf";
    repo = "wireproxy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-R1G/VtyQsl7yoDwZw+24qTdeq//qYQTQwzAPvH8f+ls=";
  };

  vendorHash = "sha256-T6RN7f05bNVL7gfhaAR0+lKZWqXvMcgjiyPldCmmvU4=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = finalAttrs.src.rev;
    command = "wireproxy --version";
    package = wireproxy;
  };

  meta = {
    description = "Wireguard client that exposes itself as a socks5 proxy";
    homepage = "https://github.com/windtf/wireproxy";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ _3JlOy-PYCCKUi ];
    mainProgram = "wireproxy";
  };
})

{
  lib,
  buildGoModule,
  fetchFromCodeberg,
}:
buildGoModule (finalAttrs: {
  pname = "nodeinfo";
  version = "1.0.0";

  src = fetchFromCodeberg {
    owner = "thefederationinfo";
    repo = "nodeinfo-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XwK3QeVDQMZD5G79XPJTAJyilVgYFVgZORHYTBI0gIQ=";
  };

  vendorHash = "sha256-P0klk3YWa2qprCUNUjiuF+Akxh246WCu4vwUAZmSDCw=";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  modRoot = "./cli";
  tags = [ "extension" ];

  meta = {
    description = "Command line tool to query nodeinfo based on a given domain";
    homepage = "https://codeberg.org/thefederationinfo/nodeinfo-go";
    changelog = "https://codeberg.org/thefederationinfo/nodeinfo-go/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers._6543 ];
    mainProgram = "nodeinfo";
  };
})

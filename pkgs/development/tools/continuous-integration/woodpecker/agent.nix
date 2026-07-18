{ buildGoModule, callPackage }:
let
  common = callPackage ./common.nix { };
in
buildGoModule {
  inherit (common)
    version
    src
    ldflags
    postInstall
    vendorHash
    ;

  pname = "woodpecker-agent";
  env.CGO_ENABLED = 0;
  subPackages = "cmd/agent";

  meta = common.meta // {
    description = "Woodpecker Continuous Integration agent";
    mainProgram = "woodpecker-agent";
  };
}

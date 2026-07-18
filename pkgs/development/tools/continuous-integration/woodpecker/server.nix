{
  buildGoModule,
  callPackage,
}:
let
  common = callPackage ./common.nix { };
in
buildGoModule (finalAttrs: {
  inherit (common)
    version
    src
    ldflags
    postInstall
    vendorHash
    ;

  pname = "woodpecker-server";

  postPatch = ''
    cp -r ${finalAttrs.passthru.webui} web/dist
  '';

  env.CGO_ENABLED = 1;
  subPackages = "cmd/server";

  passthru = {
    updateScript = ./update.sh;
    webui = callPackage ./webui.nix { };
  };

  meta = common.meta // {
    description = "Woodpecker Continuous Integration server";
    mainProgram = "woodpecker-server";
  };
})

{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
}:
let
  common = callPackage ./common.nix { };

  frontend = callPackage ./frontend.nix { };
in
buildGoModule (finalAttrs: {
  inherit (common) version src;
  pname = "openbooks";

  postPatch = ''
    cp -r ${finalAttrs.passthru.frontend} server/app/dist/
  '';

  vendorHash = "sha256-ETN5oZanDH7fOAVnfIHIoXyVof7CfEMkPSOHF2my5ys=";
  subPackages = [ "cmd/openbooks" ];

  passthru = {
    inherit frontend;
    updateScript = ./update.sh;
  };

  meta = common.meta // {
    description = "Search and Download eBooks";
    mainProgram = "openbooks";
  };
})

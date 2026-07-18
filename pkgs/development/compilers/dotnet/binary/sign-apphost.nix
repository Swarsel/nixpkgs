{
  callPackage,
  replaceVars,
}:
let
  sigtool = callPackage ../sigtool.nix { };

in
replaceVars ./sign-apphost.proj {
  codesign = "${sigtool}/bin/codesign";
}

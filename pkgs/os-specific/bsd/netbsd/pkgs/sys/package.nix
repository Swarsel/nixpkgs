{
  lib,
  bsdSetupHook,
  config,
  defaultMakeFlags,
  genassym,
  include,
  install,
  lorder,
  makeMinimal,
  mkDerivation,
  netbsdSetupHook,
  statHook,
  tsort,
  uudecode,
}:
let
  base = import ./base.nix {
    inherit
      lib
      mkDerivation
      include
      bsdSetupHook
      netbsdSetupHook
      makeMinimal
      install
      tsort
      lorder
      statHook
      uudecode
      config
      genassym
      defaultMakeFlags
      ;
  };
in
mkDerivation (
  base
  // {
    pname = "sys";
    installPhase = null;
    dontBuild = false;
    noCC = false;
  }
)

{
  lib,
  stdenv,
  fetchurl,
}:

{
  elmPackages,
  elmVersion,
  registryDat,
}:

let
  makeDotElm = import ./makeDotElm.nix {
    inherit
      stdenv
      lib
      fetchurl
      registryDat
      ;
  };
in
''
  export ELM_HOME=`pwd`/.elm
''
+ (makeDotElm elmVersion elmPackages)

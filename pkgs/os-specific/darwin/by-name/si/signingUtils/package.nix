{
  cctools,
  sigtool,
  stdenvNoCC,
}:

let
  stdenv = stdenvNoCC;
in

stdenv.mkDerivation {
  # Substituted variables
  env = {
    inherit sigtool;
    codesignAllocate = "${cctools}/bin/${cctools.targetPrefix}codesign_allocate";
  };

  installPhase = ''
    substituteAll ${./utils.sh} $out
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  name = "signing-utils";
}

{
  lib,
  stdenv,
  callPackage,
}:
let
  pname = "aptakube";
  version = "1.13.0";
  meta = {
    description = "Modern, lightweight and multi-cluster Kubernetes GUI";
    homepage = "https://aptakube.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.juliamertz ];
    platforms = lib.platforms.darwin ++ [ "x86_64-linux" ];
  };
in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix {
    inherit
      pname
      version
      meta
      ;
  }
else
  callPackage ./linux.nix {
    inherit
      pname
      version
      meta
      ;
  }

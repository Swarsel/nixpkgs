{
  stdenv,
  fetchurl,
  callPackage,
  jre,
  makeWrapper,
}:

let
  bare = callPackage ./bare.nix {
    inherit
      stdenv
      fetchurl
      makeWrapper
      jre
      ;
  };
in

stdenv.mkDerivation {
  inherit (bare) version;
  inherit (bare) meta;
  pname = "scala";

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${bare}/bin/scalac $out/bin/scalac
    ln -s ${bare}/bin/scaladoc $out/bin/scaladoc
    ln -s ${bare}/bin/scala $out/bin/scala
    ln -s ${bare}/bin/common $out/bin/common
  '';

  dontUnpack = true;
  passthru = { inherit bare; };
}

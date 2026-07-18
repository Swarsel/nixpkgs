{
  lib,
  stdenv,
  gmp,
  idris-no-deps,
  makeWrapper,
  symlinkJoin,
}:

symlinkJoin {
  inherit (idris-no-deps)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/idris \
      --run 'export IDRIS_CC=''${IDRIS_CC:-${stdenv.cc}/bin/cc}' \
      --set 'NIX_CC_WRAPPER_TARGET_HOST_${stdenv.cc.suffixSalt}' 1 \
      --prefix NIX_CFLAGS_COMPILE " " "-I${lib.getDev gmp}/include" \
      --prefix NIX_CFLAGS_LINK " " "-L${lib.getLib gmp}/lib"
  '';

  paths = [ idris-no-deps ];
}

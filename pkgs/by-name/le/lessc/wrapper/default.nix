{
  lib,
  stdenv,
  lessc,
  makeWrapper,
  plugins ? [ ],
}:

stdenv.mkDerivation {
  inherit (lessc)
    version
    src
    passthru
    meta
    ;

  pname = "lessc-with-plugins";
  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    mkdir -p $out/bin

    makeWrapper "${lib.getExe lessc}" "$out/bin/lessc" \
      --prefix NODE_PATH : "${lib.makeSearchPath "/lib/node_modules" plugins}"
  '';

  doUnpack = false;
}

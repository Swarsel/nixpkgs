{
  lib,
  stdenv,
  coq,
  itauto,
}:

let
  excluded = lib.optionals (lib.versions.isEq "8.16" itauto.version) [
    "arith.v"
    "refl_bool.v"
  ];
in

stdenv.mkDerivation {
  inherit (itauto) src version;
  pname = "coq${coq.coq-version}-itauto-test";
  doCheck = true;

  nativeCheckInputs = [
    coq
    itauto
  ];

  checkPhase = ''
    cd test-suite
    for m in *.v
    do
      echo -n ${lib.concatStringsSep " " excluded} | grep --silent $m && continue
      echo $m && coqc $m
    done
  '';

  installPhase = "touch $out";
  dontBuild = true;
  dontConfigure = true;
}

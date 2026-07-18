# Run:
#   nix-build -A nixosTests.activation-lib
{
  lib,
  stdenv,
  testers,
}:
let

  runTests = stdenv.mkDerivation {
    buildPhase = ":";

    checkPhase = ''
      ./test.sh
    '';

    doCheck = true;

    installPhase = ''
      touch $out
    '';

    name = "tests-activation-lib";

    postUnpack = ''
      patchShebangs --build .
    '';

    src = ./lib;
  };

  runShellcheck = testers.shellcheck {
    name = "activation-lib";
    src = runTests.src;
  };

in
lib.recurseIntoAttrs {
  inherit runTests runShellcheck;
}

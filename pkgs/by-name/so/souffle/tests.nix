{
  lib,
  stdenv,
  runCommand,
  souffle,
}:
let
  simpleTest =
    { commands, name }:
    stdenv.mkDerivation {
      inherit name;

      buildCommand = ''
        echo -e '.decl A(X: number)\n.output A\nA(1).' > A.dl
        ${commands}
        [ "$(cat A.csv)" = "1" ]
        touch $out
      '';

      meta.timeout = 60;
    };
in
{
  compile-in-one-step = simpleTest {
    commands = ''
      ${souffle}/bin/souffle -o A A.dl
      ./A
    '';

    name = "souffle-test-compile-in-one-step";
  };

  compile-in-two-steps = simpleTest {
    commands = ''
      ${souffle}/bin/souffle -g A.cpp A.dl
      ${souffle}/bin/souffle-compile.py A.cpp -o A
      ./A
    '';

    name = "souffle-test-compile-in-two-steps";
  };

  interpret = simpleTest {
    commands = "${souffle}/bin/souffle A.dl";
    name = "souffle-test-interpret";
  };
}

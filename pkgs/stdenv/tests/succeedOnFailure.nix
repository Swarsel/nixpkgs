{ stdenv }:

stdenv.mkDerivation {
  buildCommand = ''
    mkdir $out
    echo foo > $out/foo
    exit 1
  '';

  name = "stdenv-test-succeedOnFailure";
  passAsFile = [ "buildCommand" ];
  succeedOnFailure = true;
}

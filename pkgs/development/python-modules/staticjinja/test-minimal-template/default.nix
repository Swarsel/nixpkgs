{ stdenv, staticjinja }:

stdenv.mkDerivation {
  buildCommand = ''
    ${staticjinja}/bin/staticjinja build --srcpath ${./templates}
    grep 'Hello World!' index
    touch $out
  '';

  name = "staticjinja-test-minimal-template";
  meta.timeout = 30;
}

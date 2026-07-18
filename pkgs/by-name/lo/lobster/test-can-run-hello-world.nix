{ stdenv, lobster }:

stdenv.mkDerivation {
  buildCommand = ''
    ${lobster}/bin/lobster \
      ${lobster}/share/Lobster/samples/rosettacode/hello_world_test.lobster \
      | grep 'Goodbye, World!'
    touch $out
  '';

  name = "lobster-test-can-run-hello-world";
  meta.timeout = 10;
}

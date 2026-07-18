{
  stdenv,
  jasmin,
  jre,
}:

stdenv.mkDerivation {
  buildCommand = ''
    ${jasmin}/bin/jasmin ${./HelloWorld.j}
    ${jre}/bin/java HelloWorld | grep "Hello World"
    touch $out
  '';

  name = "jasmin-test-assemble-hello-world";
  meta.timeout = 60;
}

{
  stdenv,
  coq,
  simple-io,
}:

stdenv.mkDerivation {
  inherit (simple-io) src version;
  pname = "coq-simple-io-test";
  doCheck = true;

  nativeCheckInputs = [
    coq
    simple-io
  ];

  checkPhase = ''
    cd test
    for p in Argv.v Example.v HelloWorld.v TestExtraction.v TestOcamlbuild.v TestPervasives.v
    do
      [ -f $p ] && echo $p && coqc $p
    done
  '';

  installPhase = "touch $out";
  dontBuild = true;
  dontConfigure = true;

}

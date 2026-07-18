{
  alcotest,
  buildDunePackage,
  cppo,
  cstruct,
  hacl-star-raw,
  qcheck-core,
  secp256k1-internal,
  zarith,
}:

buildDunePackage {
  inherit (hacl-star-raw)
    version
    src
    meta
    doCheck
    ;

  pname = "hacl-star";

  nativeBuildInputs = [
    cppo
  ];

  propagatedBuildInputs = [
    hacl-star-raw
    zarith
  ];

  checkInputs = [
    alcotest
    secp256k1-internal
    qcheck-core
    cstruct
  ];

  minimalOCamlVersion = "4.08";
}

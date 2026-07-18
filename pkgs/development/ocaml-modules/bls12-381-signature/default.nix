{
  lib,
  alcotest,
  bisect_ppx,
  bls12-381,
  buildDunePackage,
  fetchzip,
  integers_stubs_js,
}:

buildDunePackage (finalAttrs: {
  pname = "bls12-381-signature";
  version = "1.0.0";

  src = fetchzip {
    url = "https://gitlab.com/nomadic-labs/cryptography/ocaml-bls12-381-signature/-/archive/${finalAttrs.version}/ocaml-bls12-381-signature-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-KaUpAT+BWxmUP5obi4loR9vVUeQmz3p3zG3CBolUuL4=";
  };

  propagatedBuildInputs = [ bls12-381 ];
  doCheck = true;

  checkInputs = [
    alcotest
    bisect_ppx
    integers_stubs_js
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Implementation of BLS signatures for the pairing-friendly curve BLS12-381";
    homepage = "https://gitlab.com/nomadic-labs/cryptography/ocaml-bls12-381-signature";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})

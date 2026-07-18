{
  lib,
  alcotest,
  buildDunePackage,
  digestif,
  fetchzip,
  mirage-crypto,
  ohex,
}:

buildDunePackage (finalAttrs: {
  pname = "pbkdf";
  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/abeaumont/ocaml-pbkdf/archive/${finalAttrs.version}.tar.gz";
    hash = "sha256-D2dXpf1D/wsJrcajU3If37tuLYjahoA/+QoXZKr1vQs=";
  };

  propagatedBuildInputs = [
    digestif
    mirage-crypto
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    ohex
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Password based key derivation functions (PBKDF) from PKCS#5";
    homepage = "https://github.com/abeaumont/ocaml-pbkdf";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})

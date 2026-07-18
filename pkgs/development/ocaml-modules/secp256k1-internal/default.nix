{
  lib,
  fetchFromGitLab,
  alcotest,
  bigstring,
  buildDunePackage,
  cstruct,
  dune-configurator,
  gmp,
  hex,
}:

buildDunePackage (finalAttrs: {
  pname = "secp256k1-internal";
  version = "0.4";

  src = fetchFromGitLab {
    owner = "nomadic-labs";
    repo = "ocaml-secp256k1-internal";
    rev = "v${finalAttrs.version}";
    hash = "sha256-amVtp94cE1NxClWJgcJvRmilnQlC7z44mORUaxvPn00=";
  };

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    gmp
    cstruct
    bigstring
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    hex
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Bindings to secp256k1 internal functions (generic operations on the curve)";
    homepage = "https://gitlab.com/nomadic-labs/ocaml-secp256k1-internal";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})

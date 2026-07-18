{
  lib,
  fetchFromGitLab,
  alcotest,
  buildDunePackage,
  hex,
  integers,
  integers_stubs_js,
  zarith,
  zarith_stubs_js ? null,
}:

buildDunePackage (finalAttrs: {
  pname = "bls12-381";
  version = "6.1.0";

  src = fetchFromGitLab {
    owner = "nomadic-labs";
    repo = "cryptography/ocaml-bls12-381";
    rev = finalAttrs.version;
    hash = "sha256-z2ZSOrXgm+XjdrY91vqxXSKhA0DyJz6JkkNljDZznX8=";
  };

  postPatch = ''
    patchShebangs ./src/*.sh
  '';

  propagatedBuildInputs = [
    zarith
    zarith_stubs_js
    integers_stubs_js
    hex
    integers
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Implementation of BLS12-381 and some cryptographic primitives built on top of it";
    homepage = "https://nomadic-labs.gitlab.io/cryptography/ocaml-bls12-381/bls12-381/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})

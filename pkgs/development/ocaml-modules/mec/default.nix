{
  lib,
  alcotest,
  bigarray-compat,
  bisect_ppx,
  buildDunePackage,
  eqaf,
  fetchzip,
  ff,
  ff-sig,
  hex,
  zarith,
}:

buildDunePackage (finalAttrs: {
  pname = "mec";
  version = "0.1.0";

  src = fetchzip {
    url = "https://gitlab.com/nomadic-labs/cryptography/ocaml-ec/-/archive/${finalAttrs.version}/ocaml-ec-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-uIcGj/exSfuuzsv6C/bnJXpYRu3OY3dcKMW/7+qwi2U=";
  };

  buildInputs = [
    zarith
  ];

  propagatedBuildInputs = [
    eqaf
    bigarray-compat
    hex
    ff-sig
    ff
    alcotest
  ];

  checkInputs = [
    alcotest
    bisect_ppx
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.12";

  meta = {
    description = "Mec - Mini Elliptic Curve library";
    homepage = "https://gitlab.com/nomadic-labs/cryptography/ocaml-ec";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})

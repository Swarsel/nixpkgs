{
  lib,
  fetchurl,
  buildDunePackage,
  domain-local-await,
  kcas,
  mirage-clock-unix,
  qcheck-stm,
  saturn,
}:

buildDunePackage (finalAttrs: {
  pname = "domainslib";
  version = "0.5.2";

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/domainslib/releases/download/${finalAttrs.version}/domainslib-${finalAttrs.version}.tbz";
    hash = "sha256-pyDs4stBsqWRrRpEotuezVVz6Le1ES6NRtDydfmvHK8=";
  };

  propagatedBuildInputs = [
    domain-local-await
    saturn
  ];

  doCheck = true;

  checkInputs = [
    kcas
    mirage-clock-unix
    qcheck-stm
  ];

  minimalOCamlVersion = "5.0";

  meta = {
    description = "Nested-parallel programming";
    homepage = "https://github.com/ocaml-multicore/domainslib";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})

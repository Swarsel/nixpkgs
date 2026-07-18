{
  lib,
  fetchurl,
  afl-persistent,
  alcotest,
  angstrom,
  base64,
  bigarray-overlap,
  bigstringaf,
  buildDunePackage,
  cmdliner,
  emile,
  fpath,
  hxd,
  ipaddr,
  jsonm,
  ke,
  mirage-crypto-rng,
  pecu,
  prettym,
  ptime,
  rosetta,
  unstrctrd,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "mrmime";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/mirage/mrmime/releases/download/v${finalAttrs.version}/mrmime-${finalAttrs.version}.tbz";
    hash = "sha256-w23xtro9WgyLLwqdwfqLMN/ZDqwpvFcEvurbsqnsJLc=";
  };

  propagatedBuildInputs = [
    angstrom
    base64
    emile
    ipaddr
    ke
    pecu
    prettym
    ptime
    rosetta
    unstrctrd
    uutf
    bigarray-overlap
    bigstringaf
  ];

  # Checks are not compatible with mirage-crypto-rng ≥ 1.0
  doCheck = false;

  checkInputs = [
    afl-persistent
    alcotest
    cmdliner
    fpath
    hxd
    jsonm
    mirage-crypto-rng
  ];

  meta = {
    description = "Parser and generator of mail in OCaml";
    homepage = "https://github.com/mirage/mrmime";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mrmime.generate";
  };
})

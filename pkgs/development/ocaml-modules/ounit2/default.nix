{
  lib,
  fetchurl,
  buildDunePackage,
  seq,
  stdlib-shims,
}:

buildDunePackage (finalAttrs: {
  pname = "ounit2";
  version = "2.2.7";

  src = fetchurl {
    url = "https://github.com/gildor478/ounit/releases/download/v${finalAttrs.version}/ounit-${finalAttrs.version}.tbz";
    hash = "sha256-kPbmO9EkClHYubL3IgWb15zgC1J2vdYji49cYTwOc4g=";
  };

  propagatedBuildInputs = [
    seq
    stdlib-shims
  ];

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Unit test framework for OCaml";
    homepage = "https://github.com/gildor478/ounit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})

{
  lib,
  fetchurl,
  buildDunePackage,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_gen_rec";
  version = "2.0.0";

  src = fetchurl {
    url = "https://github.com/flowtype/ocaml-ppx_gen_rec/releases/download/v${finalAttrs.version}/ppx_gen_rec-v${finalAttrs.version}.tbz";
    sha256 = "sha256-/mMj5UT22KQGVy1sjgEoOgPzyCYyeDPtWJYNDvQ9nlk=";
  };

  buildInputs = [ ppxlib ];
  duneVersion = "3";
  minimalOCamlVersion = "4.07";

  meta = {
    description = "Ppx rewriter that transforms a recursive module expression into a struct";
    homepage = "https://github.com/flowtype/ocaml-ppx_gen_rec";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ frontsideair ];
  };
})

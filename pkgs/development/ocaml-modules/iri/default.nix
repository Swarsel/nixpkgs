{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  sedlex,
  uunf,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "iri";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "zoggy";
    repo = "ocaml-iri";
    rev = finalAttrs.version;
    hash = "sha256-+wBQBzRkN36T3zAQWmqq/VdhgLrCnbvOouEmVg37s/w=";
    domain = "framagit.org";
  };

  propagatedBuildInputs = [
    sedlex
    uunf
    uutf
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "IRI (RFC3987) native OCaml implementation";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.vbgl ];
  };
})

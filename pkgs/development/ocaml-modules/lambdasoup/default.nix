{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  camlp-streams,
  markup,
  ocaml,
  ounit2,
}:

buildDunePackage (finalAttrs: {
  pname = "lambdasoup";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "aantron";
    repo = "lambdasoup";
    rev = finalAttrs.version;
    hash = "sha256-+d1JPU7OyQgt8pDTlwZraqPHH+OBQD1ycsELKpHT95Y=";
  };

  propagatedBuildInputs = [
    camlp-streams
    markup
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ ounit2 ];
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Functional HTML scraping and rewriting with CSS in OCaml";
    homepage = "https://aantron.github.io/lambdasoup/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };

})

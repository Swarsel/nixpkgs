{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  ezjsonm,
  omd,
  uri,
  xmlm,
}:

buildDunePackage (finalAttrs: {
  pname = "cow";
  version = "2.5.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-cow/releases/download/v${finalAttrs.version}/cow-${finalAttrs.version}.tbz";
    hash = "sha256-8rNK+5oWUbi91gXvdz/66YQu5+iXp0Co8wk0Isv6b9Y=";
  };

  propagatedBuildInputs = [
    xmlm
    uri
    ezjsonm
    omd
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Caml on the Web";

    longDescription = ''
      Writing web-applications requires a lot of skills: HTML, XML, JSON and
      Markdown, to name but a few! This library provides OCaml combinators
      for these web formats.
    '';

    homepage = "https://mirage.github.io/ocaml-cow/";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})

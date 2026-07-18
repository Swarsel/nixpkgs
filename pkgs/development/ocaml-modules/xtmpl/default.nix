{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  iri,
  logs,
  re,
  sedlex,
  uutf,
}:

buildDunePackage rec {
  pname = "xtmpl";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "zoggy";
    repo = "xtmpl";
    tag = version;
    hash = "sha256-CgVbSjHuRp+5IZdfkxGzaBP8p7pQdXu6S/MMgiPMw3E=";
    domain = "framagit.org";
  };

  propagatedBuildInputs = [
    iri
    logs
    re
    sedlex
    uutf
  ];

  meta = {
    description = "XML templating library for OCaml";
    homepage = "https://www.good-eris.net/xtmpl/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ regnat ];
  };
}

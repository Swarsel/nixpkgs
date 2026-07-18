{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage rec {
  pname = "syslog";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "geneanet";
    repo = "ocaml-syslog";
    rev = "v${version}";
    hash = "sha256-WybNZBPhv4fhjzzb95E+6ZHcZUnfROLlNF3PMBGO9ys=";
  };

  minimalOCamlVersion = "4.03";

  meta = {
    description = "Simple wrapper to access the system logger from OCaml";
    homepage = "https://github.com/geneanet/ocaml-syslog";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.rixed ];
  };
}

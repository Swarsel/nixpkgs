{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  re,
  uunf,
  uuseg,
}:

buildDunePackage rec {
  pname = "slug";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "thangngoc89";
    repo = "ocaml-slug";
    rev = version;
    sha256 = "sha256-pIk/0asSyibXbwmBSBuLwl2SS9aw6dNDDvwO+1VJGf8=";
  };

  propagatedBuildInputs = [
    re
    uunf
    uuseg
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";

  meta = {
    description = "Url safe slug generator for OCaml";
    homepage = "https://github.com/thangngoc89/ocaml-slug";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.niols ];
  };
}

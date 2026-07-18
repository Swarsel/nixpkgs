{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage rec {
  pname = "swhid_core";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "OCamlPro";
    repo = "swhid_core";
    rev = version;
    hash = "sha256-uLnVbptCvmBeNbOjGjyAWAKgzkKLDTYVFY6SNH2zf0A=";
  };

  minimalOCamlVersion = "4.03";

  meta = {
    description = "OCaml library to work with swhids";
    homepage = "https://github.com/ocamlpro/swhid_core";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}

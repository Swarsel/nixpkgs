{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  ocaml,
}:

buildDunePackage rec {
  pname = "terminal_size";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/cryptosense/terminal_size/releases/download/v${version}/terminal_size-${version}.tbz";
    hash = "sha256-1rYs0oxAcayFypUoCIdFwSTJCU7+rpFyJRRzb5lzsPs=";
  };

  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ alcotest ];
  duneVersion = "3";

  meta = {
    description = "Get the dimensions of the terminal";
    homepage = "https://github.com/cryptosense/terminal_size";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
}

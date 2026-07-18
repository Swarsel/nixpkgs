{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
  ocamlbuild,
  re,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-simple-diff";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "gjaldon";
    repo = "simple_diff";
    rev = "v${version}";
    sha256 = "sha256-OaKECUBCCt9KfdRJf3HcXTUJVxKKdYtnzOHpMPOllrk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];
  propagatedBuildInputs = [ re ];

  meta = {
    description = "Simple_diff is a pure OCaml diffing algorithm";
    homepage = "https://github.com/gjaldon/simple_diff";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ulrikstrid ];
  };
}

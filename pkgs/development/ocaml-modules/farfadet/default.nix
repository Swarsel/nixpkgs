{
  lib,
  stdenv,
  fetchurl,
  faraday,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-farfadet";
  version = "0.3";

  src = fetchurl {
    url = "https://github.com/oklm-wsh/Farfadet/releases/download/v${version}/farfadet-${version}.tbz";
    sha256 = "0nlafnp0pwx0n4aszpsk6nvcvqi9im306p4jhx70si7k3xprlr2j";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];
  propagatedBuildInputs = [ faraday ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Printf-like for Faraday library";
    homepage = "https://github.com/oklm-wsh/Farfadet";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    broken = lib.versionOlder ocaml.version "4.3";
  };
}

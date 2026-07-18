{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

let
  minimumSupportedOcamlVersion = "4.02.0";
in
stdenv.mkDerivation rec {
  inherit (topkg) installPhase;
  pname = "hmap";
  version = "0.8.1";

  src = fetchurl {
    url = "https://erratique.ch/software/hmap/releases/${pname}-${version}.tbz";
    sha256 = "10xyjy4ab87z7jnghy0wnla9wrmazgyhdwhr4hdmxxdn28dxn03a";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    ocamlbuild
    findlib
    topkg
  ];

  buildInputs = [ topkg ];
  buildPhase = "${topkg.run} build --tests true";
  doCheck = true;
  checkPhase = "${topkg.run} test";
  name = "ocaml${ocaml.version}-${pname}-${version}";

  meta = {
    description = "Heterogeneous value maps for OCaml";
    homepage = "https://erratique.ch/software/hmap";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.pmahoney ];
    broken = !(lib.versionOlder minimumSupportedOcamlVersion ocaml.version);
  };
}

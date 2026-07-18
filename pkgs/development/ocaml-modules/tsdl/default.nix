{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  ctypes,
  ctypes-foreign,
  findlib,
  ocaml,
  ocamlbuild,
  pkg-config,
  result,
  topkg,
}:

let
  pname = "tsdl";
  version = "1.2.0";
  webpage = "https://erratique.ch/software/${pname}";
in

stdenv.mkDerivation {
  inherit version;
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-${pname}";

  src = fetchurl {
    url = "${webpage}/releases/${pname}-${version}.tbz";
    hash = "sha256-IhB/qCh6KVfTQNFoTdxmSRRd6uMq/9OpdGvx6uqliAY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];

  propagatedBuildInputs = [
    SDL2
    ctypes
    ctypes-foreign
  ];

  preConfigure = ''
    # The following is done to avoid an additional dependency (ncurses)
    # due to linking in the custom bytecode runtime. Instead, just
    # compile directly into a native binary, even if it's just a
    # temporary build product.
    substituteInPlace myocamlbuild.ml \
      --replace ".byte" ".native"
  '';

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Thin bindings to the cross-platform SDL library";
    homepage = webpage;
    license = lib.licenses.isc;
    broken = lib.versionOlder ocaml.version "4.03";
  };
}

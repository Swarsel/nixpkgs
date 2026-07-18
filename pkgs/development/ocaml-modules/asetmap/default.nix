{
  lib,
  fetchurl,
  buildDunePackage,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

buildDunePackage (finalAttrs: {
  inherit (topkg) buildPhase installPhase;
  pname = "asetmap";
  version = "0.8.1";

  src = fetchurl {
    url = "https://github.com/dbuenzli/asetmap/archive/refs/tags/v${finalAttrs.version}.tar.gz";
    sha256 = "051ky0k62xp4inwi6isif56hx5ggazv4jrl7s5lpvn9cj8329frj";
  };

  strictDeps = true;

  nativeBuildInputs = [
    topkg
    findlib
    ocamlbuild
    ocaml
  ];

  buildInputs = [ topkg ];

  meta = {
    inherit (ocaml.meta) platforms;
    license = lib.licenses.isc;
  };
})

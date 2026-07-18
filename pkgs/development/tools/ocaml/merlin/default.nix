{
  lib,
  fetchurl,
  buildDunePackage,
  csexp,
  dot-merlin-reader,
  dune_2,
  fetchpatch,
  menhirSdk,
  replaceVars,
  result,
  seq,
  yojson,
}:

buildDunePackage rec {
  pname = "merlin";
  version = "3.8.0";

  src = fetchurl {
    url = "https://github.com/ocaml/merlin/releases/download/v${version}/merlin-${version}.tbz";
    sha256 = "sha256-wmBGNwXL3BduF4o1sUXtAOUHJ4xmMvsWAxl/QdNj/28=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      dot-merlin-reader = "${dot-merlin-reader}/bin/dot-merlin-reader";
      dune = "${dune_2}/bin/dune";
    })
    # https://github.com/ocaml/merlin/pull/1798
    (fetchpatch {
      hash = "sha256-HmdTISE/s45C5cwLgsCHNUW6OAPSsvQ/GcJE6VDEobs=";
      name = "vim-python-12-syntax-warning-fix.patch";
      url = "https://github.com/ocaml/merlin/commit/9e0c47b0d5fd0c4edc37c4c7ce927b155877557d.patch";
    })
  ];

  strictDeps = true;

  buildInputs = [
    dot-merlin-reader
    yojson
    csexp
    result
    seq
    menhirSdk
  ];

  minimalOCamlVersion = "4.02.3";

  meta = {
    description = "Editor-independent tool to ease the development of programs in OCaml";
    homepage = "https://github.com/ocaml/merlin";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
}

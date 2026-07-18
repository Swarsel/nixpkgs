{
  lib,
  bitstring,
  buildDunePackage,
  fetchpatch,
  ocaml,
  ounit,
  ppxlib,
}:

buildDunePackage {
  inherit (bitstring) version src;
  pname = "ppx_bitstring";

  patches = lib.optional (lib.versionAtLeast ppxlib.version "0.36") (fetchpatch {
    hash = "sha256-wtpSnGOzIUTmB3LhyHGopecy7F/5SYFOwaR6eReV+6g=";
    url = "https://github.com/xguerin/bitstring/commit/b42d4924cbb5ec5fd5309e6807852b63f456f35d.patch";
  });

  buildInputs = [
    bitstring
    ppxlib
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ ounit ];

  meta = bitstring.meta // {
    description = "Bitstrings and bitstring matching for OCaml - PPX extension";
    broken = lib.versionOlder ppxlib.version "0.18.0";
  };
}
